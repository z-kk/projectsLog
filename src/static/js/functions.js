function select(selector) {
    return document.querySelector(selector);
}

function selectAll(selector) {
    return document.querySelectorAll(selector);
}

function setNode(node, content) {
    select(node).innerHTML = content;
}

function hide(e) {
    e.style.display = "none";
}

function show(e) {
    e.style.display = "";
}
