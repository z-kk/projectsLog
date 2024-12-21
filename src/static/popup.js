function showPopup() {
    select('#lay').style.display = "block";
    select('#pop').style.display = "block";
}

function hidePopup() {
    hide(select('#lay'));
    hide(select('#pop'));
}

select('#lay').addEventListener('click', function() {
    hidePopup();
});
