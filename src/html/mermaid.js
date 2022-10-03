mermaid.initialize({startOnLoad: true});
select('#mmdbtn').addEventListener('click', updateMermaidGraph);

function updateMermaidGraph() {
    fetch("/api/mermaid").then(response => {
        if (!response.ok) {
            throw new Error("response error");
        }
        return response.text();
    }).then(txt => {
        if (txt != "") {
            let mmd = select("#mermaid");
            mmd.innerHTML = txt;
            delete mmd.dataset.processed;
            mermaid.init();
        }
    }).catch(error => {
        alert(error);
    });
}
