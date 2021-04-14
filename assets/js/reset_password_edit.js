import { encryptPassword } from "./encryption";

function doSubmit(e) {
    e.preventDefault();
    let form = document.getElementsByTagName("form")[0];
    encryptPassword(form.elements.user_passphrase.value)
        .then(k => {
            form.elements.user_password.value = k;
        })
        .then(() => encryptPassword(form.elements.user_passphrase_confirmation.value))
        .then(k => {
            form.elements.user_password_confirmation.value = k;
        })
        .then(() => form.submit());
    return false;
}

document.addEventListener("DOMContentLoaded", () => {
    document.getElementsByTagName("form")[0].onsubmit = doSubmit;
})
