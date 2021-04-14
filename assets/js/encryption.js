function encryptPassword(password) {
    if (password.length < 1) {
        throw new Error();
    }
    const encoder = new TextEncoder("utf-8");
    const passKey = encoder.encode(password);

    return window.crypto.subtle.importKey(
        "raw",
        passKey,
        {name: "PBKDF2"},
        false,
        ["deriveKey"]).
        then(key => window.crypto.subtle.deriveKey(
            {
                name: "PBKDF2",
                salt: new Uint8Array(8),
                iterations: 1000,
                hash: "SHA-512"
            },
            key,
            {name: "AES-CBC", length: 256},
            true,
            ["encrypt"]))
        .then(webKey => crypto.subtle.exportKey("raw", webKey))
        .then(buffer => btoa(String.fromCharCode(...new Uint8Array(buffer))))
}


function decode(text, key) {
    if(text) {
        return window.crypto.subtle.importKey(
            "jwk", key,
            "AES-GCM",
            true,
            ["encrypt", "decrypt"])
            .then(key => window.crypto.subtle.decrypt(
                {name: "AES-GCM", iv: new Uint8Array(12)},
                key,
                Uint8Array.from(atob(text), c => c.charCodeAt(0))))
            .then(x => (new TextDecoder("utf-8")).decode(x))
    } else {
        return Promise.resolve("");
    }
 }

export { encryptPassword, decode };
