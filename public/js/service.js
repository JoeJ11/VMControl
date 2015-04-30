/**
 * Created by Joe on 15/4/20.
 */

var timer = null

function get_progress(id) {
    $.ajax({
        url: '/dispatches/' + id + '/progress',
        type: 'get',
        success: function(data) {
            if (data['progress'] == -1) {
                document.getElementById('stage_1').className = 'bg-danger'
                document.getElementById('stage_2').className = 'bg-danger'
                document.getElementById('stage_3').className = 'bg-danger'
            }
            else if (data['progress'] == 0) {
            }
            else if (data['progress'] == 1) {
                document.getElementById('stage_1').className = 'bg-success'
            }
            else if (data['progress'] == 2) {
                document.getElementById('stage_2').className = 'bg-success'
            }
            else if (data['progress'] == 3) {
                document.getElementById('stage_3').className = 'bg-success'
                document.getElementById('iframe').src = data['url'] + '?innerframe=true'
                clearInterval(timer);
            }
            else {
                document.getElementById('stage_1').className = 'bg-warning'
                document.getElementById('stage_2').className = 'bg-warning'
                document.getElementById('stage_3').className = 'bg-warning'
            }
        }
    })
}