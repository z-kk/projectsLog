const holiday = [];

function isWaitOrHide(val) {
    const sts = taskStatus[val];
    return (sts == "Waiting" || sts == "Hide");
}

function filterStatus(node, containHide) {
    const res = node.filter((val) => { return taskStatus[val.status] != "Done" });
    if (containHide) {
        return res;
    } else {
        return res.filter((val) => { return taskStatus[val.status] != "Hide" });
    }
}

function setMermaid(data) {
    const today = new Date();
    const d = select(".mermaid");
    delete d.dataset.processed;
    let mmd = `gantt
        dateFormat YYYY-MM-DD
        axisFormat %m/%d
        excludes weekends ${holiday.join(" ")}
    \n`
    for (proj of data) {
        if (filterStatus(proj.data, false).length == 0) {
            continue;
        }
        if (proj.proj == "") {
            proj.proj = "other";
        }
        mmd += `    section ${proj.proj}\n`;
        for (title of filterStatus(proj.data, false)) {
            let from = getDateString(today);
            if (isWaitOrHide(title.status) && title.for > from) {
                from = title.for;
            }
            let due = new Date(today.getTime());
            if (title.due) {
                due = new Date(title.due);
            }
            due.setDate(due.getDate() + 1);
            mmd += `        ${title.title}: ${title.uuid},${from},${getDateString(due)}\n`;
            for (child of filterStatus(title.children, false)) {
                from = getDateString(today);
                if (isWaitOrHide(child.status) && child.for > from) {
                    from = child.for;
                }
                due = new Date(today.getTime());
                if (child.due) {
                    due = new Date(child.due);
                }
                due.setDate(due.getDate() + 1);
                mmd += `        ${child.title}: ${child.uuid},${from},${getDateString(due)}\n`;
            }
        }
    }
    d.innerHTML = mmd;

    const mermaidUrl = "https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs";
    import(mermaidUrl).then(module => {
        if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
            module.default.init({theme: "dark", themeCSS: ".exclude-range {fill: var(--nc-bg-3)}; .task {fill: var(--nc-ac-1)}"});
        } else {
            module.default.init();
        }
    });
}

self.window.addEventListener('load', function() {
    fetch("https://holidays-jp.github.io/api/v1/date.json").then(response => {
        if (!response.ok) {
            throw new Error("response error");
        }
        return response.json();
    }).then(data => {
        for (key in data) {
            holiday.push(key);
        }
    }).catch(err => {
        alert(err);
    });

    fetch(appName + "/api/taskdata", {
        method: "GET",
    }).then(response => {
        if (!response.ok) {
            throw new Error("response error");
        }
        return response.json();
    }).then(data => {
        setMermaid(data);
    }).catch(err => {
        alert(err);
    });
});
