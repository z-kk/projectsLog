function addRow(evt) {
    let ipt = evt.target;
    let val = ipt.value;
    if (val == "") {
        return;
    }
    let tb = select('tbody');
    let row = ipt.parentElement.parentElement;
    let idx = row.rowIndex;
    if (idx == tb.children.length) {
        let r = row.cloneNode(true);
        r.querySelector('.content').value = "";
        r.querySelector('.fromTime').value = val;
        r.querySelector('.toTime').value = "";
        r.querySelector('.proj').name = "proj_" + idx;
        r.querySelector('.cat').name = "cat_" + idx;
        r.querySelector('.content').name = "content_" + idx;
        r.querySelector('.fromTime').name = "from_" + idx;
        r.querySelector('.toTime').name = "to_" + idx;
        r.querySelector('.toTime').addEventListener('blur', addRow);
        tb.appendChild(r);
        r.querySelector('.proj').focus();
        ipt.removeEventListener('blur', addRow);
    }
}

window.addEventListener('load', function() {
    let tb = select('tbody');
    let row = tb.children[tb.children.length - 1];
    row.querySelector('.toTime').addEventListener('blur', addRow);
});
