import { decode } from "./encryption";

window.onload = function() {
    let key = JSON.parse(localStorage.getItem("EK"));
    let bookmarks = document.getElementsByClassName("bookmark");
    Array.from(bookmarks).forEach(bookmark => {
        let a = bookmark.getElementsByTagName('a')[0];
        let to_decode = [
            decode(a.dataset.title, key).then(title => {
                a.innerHTML = "";
                a.appendChild(document.createTextNode(title))
            }),
            decode(a.dataset.url, key).then(url => { a.href = url }),
        ];

        Promise.all(to_decode).then(() => {
            bookmark.style.visibility = "visible";
        })
    });
}

function bookmarkFilter(){
	let bookmarks = document.getElementsByClassName("bookmark");
	Array.from(bookmarks).forEach(bookmark => {
		if ( bookmark.getElementsByTagName('a')[0].innerHTML.toLowerCase().indexOf(document.getElementById("search").value.toLowerCase()) == -1 ) {
			bookmark.style.display = 'none';
		} else {
			bookmark.style.display = '';
		}
	})
}
