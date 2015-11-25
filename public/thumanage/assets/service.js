/**
 * Created by Joe on 15/4/20.
 */

var timer = null
var editor_url = ''
var notebook_url = ''

function get_progress(id) {
    $.ajax({
        url: '/dispatches/' + id + '/progress',
        type: 'get',
        success: function(data) {
            if (data['progress'] == -1) {
                document.getElementById('stage_1').className = 'bg-danger'
                document.getElementById('stage_2').className = 'bg-danger'
                document.getElementById('stage_3').className = 'bg-danger'
                document.getElementById('failure_info').style.display = "block"
                clearInterval(timer)
            }
            else if (data['progress'] == 0) {
            }
            else if (data['progress'] == 1) {
                document.getElementById('stage_1').className = 'bg-success'
            }
            else if (data['progress'] == 2) {
                document.getElementById('stage_1').className = 'bg-success'
                document.getElementById('stage_2').className = 'bg-success'
            }
            else if (data['progress'] == 3) {
                // document.getElementById('stage_1').className = 'bg-success'
                // document.getElementById('stage_2').className = 'bg-success'
                // document.getElementById('stage_3').className = 'bg-success'
                document.getElementById('success_info').style.display = "block"
                document.getElementById("stage_1").style.display = "none"
                document.getElementById("stage_2").style.display = "none"
                document.getElementById("stage_3").style.display = "none"
                document.getElementById('myButton').style.display = "block"
                document.getElementById('BtnEditor').style.display = "block"
                // document.getElementById('BtnNotebook').style.display = "block"
                document.getElementById('iframe').src = data['url']
                editor_url = data['editor_url']
                notebook_url = data['notebook_url']
                clearInterval(timer);
            }
            else {
                document.getElementById('stage_1').className = 'bg-warning'
                document.getElementById('stage_2').className = 'bg-warning'
                document.getElementById('stage_3').className = 'bg-warning'
                document.getElementById('failure_info').style.display = "block"
                clearInterval(timer)
            }
        }
    })
};

function btn_open_editor() {
  window.open(editor_url)
};

function btn_open_notebook() {
  window.open(notebook_url)
};
