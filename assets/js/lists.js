import { decode } from "./encryption";

window.onload = function() {
    let key = JSON.parse(localStorage.getItem("EK"));
    let links = document.getElementsByClassName("read-link");
    Array.from(links).forEach(link => {
        let a = link.getElementsByTagName('a')[0];
        let favicon = link.getElementsByTagName('img')[0];
        let to_decode = [
            decode(a.dataset.title, key).then(title => {
                a.innerHTML = "";
                a.appendChild(document.createTextNode(title))
            }),
            decode(a.dataset.url, key).then(url => {
                let to = new URL(a.href);
                to.searchParams.append("to", url);
                a.href = to;
            }),
            decode(favicon.dataset.url, key).then(url => { if (url) { favicon.src = url } })
        ];

        Promise.all(to_decode).then(() => {
            link.style.visibility = "visible";
        })
            .catch(console.error)
    });
}
