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
                document.getElementById('infoBar').textContent = 'Please wait and try again.'
            }
            else if (data['progress'] == 0) {
                document.getElementById('infoBar').textContent = '正在等待...'
            }
            else if (data['progress'] == 1) {
                document.getElementById('infoBar').textContent = '正在准备虚拟机环境...'
            }
            else if (data['progress'] == 2) {
                document.getElementById('infoBar').textContent = '正在准备代理...'
            }
            else if (data['progress'] == 3) {
                document.getElementById('infoBar').textContent = '准备就绪！'
                document.getElementById('iframe').src = data['url']
                clearInterval(timer);
            }
            else {
                document.getElementById('infoBar').textContent = 'finished.'
            }
        }
    })
}