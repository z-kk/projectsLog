function update() {
    let data = {};
    data["day"] = select("#day").value;
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
    neel.callNim("updateLog", data);
    neel.callNim("updateCalcTable", select("#from_day").value, select("#to_day").value);
}

function setEvent() {
    let rows = selectAll("#inputtable tbody tr");
    let tipt = rows[rows.length - 1].querySelector(".toTime")
    tipt.addEventListener("blur", addRow);

    rows.forEach(row => {
        let ipt = row.querySelector(".content");
        ipt.setAttribute("list", select("datalist").id);
        ipt.addEventListener("focus", function(evt) {
            let row = evt.target.parentElement.parentElement;
            let data = {};
            data["proj"] = row.querySelector(".proj").value;
            data["category"] = row.querySelector(".cat").value;
            neel.callNim("setDataList", data);
        });
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
        r.querySelector(".fromTime").value = val;
        r.querySelector(".toTime").value = "";
        r.querySelector(".toTime").addEventListener("blur", addRow);
        tb.appendChild(r);
        r.querySelector(".proj").focus();
        ipt.removeEventListener("blur", addRow);
    }
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

window.addEventListener('load', function() {
    neel.callNim("initPage");
});
