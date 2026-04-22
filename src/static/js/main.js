function update() {
    let day = select("#day").value;
    select("#from_day").value = day;
    let data = {};
    data["day"] = day;
    data["rows"] = [];
    for (row of selectAll("#inputtable tbody tr")) {
        let rowData = {};
        rowData["proj"] = row.querySelector("select.proj").value;
        rowData["cat"] = row.querySelector("select.cat").value;
        rowData["content"] = row.querySelector("input.content").value;
        rowData["fromTime"] = row.querySelector("input.fromTime").value;
        rowData["toTime"] = row.querySelector("input.toTime").value;
        data["rows"].push(rowData);
    }
    let dataStr = JSON.stringify(data);
    webui.updateLog(dataStr);
}

function setCalcTable() {
    webui.calcTable(select("#from_day").value, select("#to_day").value).then(resp => {
        setNode("#calctable", resp);
        showDialog();
    });
}

function setEvent() {
    let rows = selectAll("#inputtable tbody tr");
    let tipt = rows[rows.length - 1].querySelector(".toTime");
    tipt.addEventListener("blur", addRow);

    rows.forEach(row => {
        setFocusEvent(row);
    });
}

function addRow(evt) {
    let ipt = evt.target;
    let val = ipt.value;
    if (val == "") {
        return;
    }
    let tb = select("#inputtable tbody");
    let row = ipt.parentElement.parentElement;
    if (row.rowIndex == tb.children.length) {
        let r = row.cloneNode(true);
        r.querySelector(".content").value = "";
        setFocusEvent(r);
        r.querySelector(".fromTime").value = val;
        r.querySelector(".toTime").value = "";
        r.querySelector(".toTime").addEventListener("blur", addRow);
        tb.appendChild(r);
        r.querySelector(".proj").focus();
        ipt.removeEventListener("blur", addRow);
    }
}

function setFocusEvent(row) {
    let ipt = row.querySelector(".content");
    let dl = select("datalist");
    ipt.setAttribute("list", dl.id);
    ipt.addEventListener("focus", function(evt) {
        let row = evt.target.parentElement.parentElement;
        let data = {};
        data["proj"] = row.querySelector(".proj").value;
        data["category"] = row.querySelector(".cat").value;
        let dataStr = JSON.stringify(data);
        webui.dataList(dataStr).then(resp => {
            dl.innerHTML = resp;
        });
    });
}

function showDialog() {
    select("dialog").showModal();
    select("#updatebtn").focus();
}

function closeDialog() {
    select("dialog").close();
}

function showAlert(msg) {
    alert(msg);
}

function init() {
    webui.mainPage().then(resp => {
        setNode("main", resp);
        select("#day").addEventListener("change", function(evt) {
            let day = evt.target.value;
            if (day == "") {
                return;
            }
            webui.inputTable(day).then(resp => {
                setNode("#inputtable", resp);
                setEvent();
            });
        });
        setEvent();
    });
}
