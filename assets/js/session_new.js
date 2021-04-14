import { encryptPassword } from "./encryption";

function setEK(password, salt, iterations) {
    const encoder = new TextEncoder("utf-8");
    const saltBuffer = encoder.encode(salt);

    return window.crypto.subtle.importKey("raw", encoder.encode(password), {name: "PBKDF2"}, false, ["deriveKey"])
        .then(key => window.crypto.subtle.deriveKey(
            {name: "PBKDF2", hash: "SHA-256", salt: saltBuffer, iterations: iterations},
            key,
            {name: "AES-GCM", length: 256},
            true,
            ["encrypt", "decrypt", "wrapKey", "unwrapKey"]
        ))
        .then(key => window.crypto.subtle.exportKey("jwk", key))
        .then(jwk => {
            localStorage.setItem("EK", JSON.stringify(jwk));
            return Promise.resolve("success");
        })
}


function doSubmit(e) {
    e.preventDefault();
    let form = document.getElementsByTagName("form")[0];
    let password = form.elements.user_passphrase.value;
    setEK(password, "", 15000)
        .then(() => encryptPassword(password))
        .then(k => {
            form.elements.user_password.value = k;
        })
        .then(() => form.submit());
    return false;
}


document.addEventListener("DOMContentLoaded", () => {
    document.getElementsByTagName("form")[0].onsubmit = doSubmit;
})
