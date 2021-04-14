import { decode } from "./encryption";

function traverse(json, key) {
    return Promise.all(Object.keys(json).map(k => {
        if (typeof json[k] === 'object') {
            return traverse(json[k], key)
        } else {
            switch(k) {
            case "title":
                return decode(json[k], key).then(x => json[k] = x)
                break;
            case "url":
                return decode(json[k], key).then(x => json[k] = x)
                break;
            case "favicon":
                return decode(json[k], key).then(x => json[k] = x)
                break;
            default:
                return "ok"
            }
        }
    }))
}

document.addEventListener("DOMContentLoaded", function(){
    document.querySelectorAll('.dl').forEach(a => {
        a.onclick = (e) => {
            e.preventDefault();
            fetch(a.href)
                .then(r => {
                    if (r.ok) {
                        return r.json()
                    } else {
                        return Promise.reject("network error")
                    }
                })
                .then(json => {
                    let key = JSON.parse(localStorage.getItem("EK"));
                    return Promise.all([json, traverse(json, key)]);
                })
                .then(x => {
                    let json = x[0];
                    var _a = document.createElement('a');
                    _a.setAttribute(
                        'href',
                        'data:application/json;charset=utf-8,' + encodeURIComponent(JSON.stringify(json)));
                    _a.setAttribute('download', a.download);
                    _a.style.display = 'none';
                    document.body.appendChild(_a);
                    _a.click();
                    document.body.removeChild(_a);
                })
        }
    });
});
