function setBlurEvent() {
    let tb = select('tbody');
    let row = tb.children[tb.children.length - 1];
    row.querySelector('.toTime').addEventListener('blur', addRow);
}

function setFocusEvent() {
    let list = document.createElement("datalist");
    list.id = "dlist";
    select('#inputtable').append(list);
    for (let ipt of selectAll('.content')) {
        ipt.setAttribute("list", list.id);
        ipt.addEventListener('focus', function() {
            while (list.children.length > 0) {
                list.children[0].remove();
            }
            let fd = new FormData();
            fd.append("proj", ipt.parentElement.parentElement.querySelector(".proj").value);
            fd.append("category", ipt.parentElement.parentElement.querySelector(".cat").value);
            fetch("/api/getcontents", {
                method: 'POST',
                body: fd,
            }).then(response => {
                if (!response.ok) {
                    throw new Error("response error");
                }
                return response.text();
            }).then(txt => {
                for (let cont of txt.split("\n")) {
                    let opt = document.createElement("option");
                    opt.value = cont;
                    list.append(opt);
                }
            }).catch(error => {
                alert(error);
            });
        });
    }
}

function calcProjectsLog() {
    let fd = new FormData(select('form'));
    fetch("/api/getcalctable", {
        method: 'POST',
        body: fd,
    }).then(response => {
        if (!response.ok) {
            hidePopup();
            throw new Error("response error");
        }
        return response.text();
    }).then(txt => {
        select('#calctable').innerHTML = txt;
        showPopup();
    }).catch(error => {
        alert(error);
    });
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
            select("#inputtable").innerHTML = data["body"];
            setBlurEvent();
            setFocusEvent();
            let day = select("#day").value;
            select("#from_day").value = day;
            select("#to_day").value = day;
            calcProjectsLog();
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
    setBlurEvent();
    setFocusEvent();

    select('#day').addEventListener('change', function(e) {
        let day = e.target.value;
        if (day == "") {
            return;
        }
        var fd = new FormData();
        fd.append("day", day);
        fetch("/api/getinputtable", {
            method: 'POST',
            body: fd,
        }).then(response => {
            if (!response.ok) {
                throw new Error("response error");
            }
            return response.text();
        }).then(txt => {
            select('#inputtable').innerHTML = txt;
            setBlurEvent();
            setFocusEvent();
        }).catch(error => {
            alert(error);
        });
    });

    select('#okbtn').addEventListener('click', updateProjectsLog);
    select('#updatebtn').addEventListener('click', calcProjectsLog);
});
