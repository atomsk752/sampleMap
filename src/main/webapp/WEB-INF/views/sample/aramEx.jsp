<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<title>Simple Map</title>
<meta name="viewport" content="initial-scale=1.0">
<meta charset="utf-8">
<style>
/* Always set the map height explicitly to define the size of the div
     * element that contains the map. */
#map {
     width: 80%;
      background-color: deepskyblue;
      height: 98vh;
      float: left;
}
/* Optional: Makes the sample page fill the window. */
html, body {
    height: 100%;
    margin: 0;
    padding: 0;
}
 .container {
      width: 100%;
      background-color: #999999;
      margin: 0 auto;
    }
    .sidebar {
      float: right;
      width: 20%;
      background-color: tomato;
      height: 98vh;
    }
    #sortable {
      list-style-type: none;
      margin-left: 10%;
      padding: 0;
      width: 80%;
    }
    #sortable li {
      margin: 3px 3px 3px 3px;
      padding: 0.4em;
      padding-left: 1.5em;
      font-size: 1.3em;
      height: 30px;
    }
    #sortable li span {
      position: absolute;
      margin-left: -1.3em;
    }
</style>
</head>
<body>
    <div class="container">
  <div id="map" class="map"></div>
  <div class="sidebar">
    <button id="jsonBtn">JSON 데이터 보기</button>
    <ul id="sortable">
    </ul>
  </div>
</div>
    <script src="https://code.jquery.com/jquery-1.12.4.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
    <script>
 
        $(document).ready(function() {
            
            var poly;
            var map;
            var mindMapArr = [];
            var recommendArr = [];
            var course = [];
            var markerArr = [];
            var recMarkerArr = [];
            
            
            $(".sidebar").on("click", function() {
                $("#sortable").html(JSON.stringify(course));
            })
            
            
            //get mindmap data
            $.getJSON("/sample/dataEx.json", function(json1) {
                $.each(json1, function(key, data) {  
                    mindMapArr.push(data);
                    course.push(data); 
                }); // end each
            });
            
            //get recommend data
            $.getJSON("/sample/dataEx2.json", function(json2) {
                $.each(json2, function(key, data) { 
                    recommendArr.push(data);
                }); // end each
            });
        });
        
        
        // draw path
        function drawPath(arr) {
            poly = new google.maps.Polyline({ //선분 모양 설정
                strokeColor : '#000000',
                strokeOpacity : 1.0,
                strokeWeight : 3
            });
            for (var i = 0; i < arr.length; i++) {
                poly.getPath().push(new google.maps.LatLng(arr[i].lat, arr[i].lng));
            }
            poly.setMap(map);
        }
        
        
        // draw marker
        function drawMarker(arr) {
             for (var i = 0; i < arr.length; i++) {
                 
                 var marker = new google.maps.Marker({
                     position : arr[i],
                     title : arr[i].title,
                     descs : arr[i].descs,
                     myPos : arr[i],
                     map : map
                 });
                 markerArr.length < mindMapArr.length ? markerArr.push(marker) : recMarkerArr.push(marker);
                 drawInfoWin(marker);
                 addPath(marker);
            }//end for 
        }
        
        
        //draw infowindow
        function drawInfoWin(marker) {
            var infoWindow = new google.maps.InfoWindow;
            
            google.maps.event.addListener(marker, 'mouseover', function(){
                var str = "<div><strong>"
                    str += marker.title;
                    str += "</strong>";
                    str += "<br><text>" + marker.descs;
                    str += "</text></div>";
                    infoWindow.setContent(str);
                    infoWindow.open(map, marker);
            });
            google.maps.event.addListener(marker, 'mouseout', function(){
                infoWindow.close();
            });
        }
        
        //add path when marker clicked
        function addPath(marker) {
            google.maps.event.addListener(marker, "click", function() {
            	
                poly = new google.maps.Polyline({ //선분 모양 설정
                    strokeColor : '#000000',
                    strokeOpacity : 1.0,
                    strokeWeight : 3
                });
                course.push(marker.myPos);
                markerArr.push(marker);
                checkDupl(marker);
                drawList(course);
            });
        }
        
        //check duplication
        function checkDupl(marker) {
            var uniq = course.reduce(function(a, b) {
                if (a.indexOf(b) < 0)
                    a.push(b);
                return a;
            }, []);
            if (uniq.length == course.length) { //폴리 연결시 중복체크
                poly.getPath().push(marker.position);
            }else{
                course = uniq;
                alert("이미 선택된 경로입니다.");
            }   
        }
        
        //draw list
        function drawList(arr) {
            var str = "";
            $("#sortable").html("");
            for (var i = 0; i < arr.length; i++) {
                (function(arr) {
                    str = "<li class='courseList' data-idx ='"+i+"'><span class='ui-icon ui-icon-arrowthick-2-n-s'></span>" 
                            + course[i].title;
                    str += "</li>";
                    $(".sidebar ul").append(str);
                })(course);
            }
        }
        
        //rearrange idx
        function reArrangeIdx(){
            var liList = $("#sortable").find("li");
            var arr = [];
            for(var i = 0; i < liList.length; i++){
                $(liList[i]).attr("data-idx", i);
            }
        }
        
        //redraw marker
        function redrawMarker(arr){
            for(var i = 0;i < markerArr.length; i++){
                arr[i].setMap(null);
                poly.getPath().pop(arr[i].position);
            }
             for (var i = 0; i < arr.length; i++) { //마인드맵 마커 생성
                 arr[i].setMap(map);
                 poly.getPath().push(arr[i].position); //경로 그리기   
             }
        }
        
        
        // initialize map
        function initMap() {
            map = new google.maps.Map(document.getElementById('map'), {
                center : course[course.length - 1],
                zoom : 15,
                minZoom : 13
            });
            
            drawMarker(course);
            drawMarker(recommendArr);
            drawPath(course);
            drawList(course);
        }
        
        // sort list
        $(function () {
            $("#sortable").sortable({
                update: function() {
                    console.log("ddddd");
                    var liList = $("#sortable").find("li");                    
                    var arr = [];
                    for(var i = 0; i < liList.length; i++){
                        arr.push($(liList[i]).attr("data-idx"));
                    }
                    var temp = [];
                    var tempCourse = [];
                    
                    for(var i = 0; i < liList.length; i++){
                        temp.push(markerArr[arr[i]]);
                        tempCourse.push(course[arr[i]]);
                    }
                    
                    markerArr = temp;
                    course = tempCourse;
                    redrawMarker(markerArr);
                    reArrangeIdx();
                }
            });
          });
    </script>
    <script async defer
        src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCIdmqOHKEfF4mfn6EXtuLeeP2-h3yJr6A&callback=initMap">
        
    </script>
</body>
</html>