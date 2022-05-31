function calcProjectsLog(from, to) {
}

function updateProjectsLog() {
    let btn = select('#okbtn');
    btn.disabled = true;

    let fd = new FormData(select('form'));
    fetch("/api/update", {
        method: 'POST',
        body: fd,
    }).then(response => {
        if (!response.ok) {
            hidePopup();
            throw new Error("response error");
        }
        return response.json();
    }).then(data => {
        if (data["result"]) {
            let day = select("#day").value;
            calcProjectsLog(day, day);
        } else {
            alert("登録に失敗しました\n" + data["exception"]);
        }
    }).catch(error => {
        alert(error);
    }).finally(_ => {
        btn.disabled = false;
    });
}

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

    select('#okbtn').addEventListener('click', updateProjectsLog);
});