import { decode } from "./encryption";

function setDL(which) {
    document.getElementById(`downloads-full`).style.display = "none";
    document.getElementById(`downloads-lite`).style.display = "none";

    document.getElementById(`dl-tab-full`).classList.remove('selected');
    document.getElementById(`dl-tab-lite`).classList.remove('selected');

    document.getElementById(`downloads-${which}`).style.display = "block";
    document.getElementById(`dl-tab-${which}`).classList.add('selected');
}

window.onload = function() {
    let key = JSON.parse(localStorage.getItem("EK"));
    let tabs = document.getElementsByClassName("tab");
    Array.from(tabs).forEach(tab => {
        let link = tab.getElementsByTagName('a')[0];
        let favicon = tab.getElementsByTagName('img')[0];
        let to_decode = [
            decode(link.dataset.title, key).then(title => {
                link.innerHTML = "";
                link.appendChild(document.createTextNode(title))
            }),
            decode(link.dataset.url, key).then(url => { link.href = url }),
            decode(favicon.dataset.url, key).then(url => { if (url) { favicon.src = url } }),
        ];
        Promise.all(to_decode).then(() => {
            tab.style.visibility = "visible";
        })
    });
}
