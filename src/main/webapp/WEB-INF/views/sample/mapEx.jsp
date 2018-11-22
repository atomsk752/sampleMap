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
			<ul id="sortable">
			</ul>
		</div>
	</div>
	<script src="https://code.jquery.com/jquery-1.12.4.js"></script>
	<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
	<script>

		var map;
		var mindMapArr = new Array();
		var recommendArr = new Array();
		var course = new Array();
		var markerArr = new Array();
		var poly;

		$(document).ready(function() {

			// 마인드맵 JSON 데이터 가져오기 
			$.getJSON("/sample/dataEx.json", function(json1) {

				$(json1).each(function(key, data) {

					mindMapArr.push(data);
					course.push(data);

				}); // end each

			}); // end getJSON

			// 추천 JSON 데이터 가져오기 
			$.getJSON("/sample/dataEx2.json", function(json2) {

				$.each(json2, function(key, data) {

					recommendArr.push(data);

				}); // end each
			}); // end getJSON

		});
		//맵 생성 및 설정
		function initMap() {

			map = new google.maps.Map(document.getElementById('map'), {
				center : course[course.length - 1],
				zoom : 15,
				minZoom : 13
			//확대 가능한 최소 크기

			});
			//경로 모양 설정
			poly = new google.maps.Polyline({
				strokeColor : '#000000',
				strokeOpacity : 1.0,
				strokeWeight : 3
			});

			initMarker();

			poly.setMap(map);
		}
		
		

		//기존, 추천 마커 생성 및 경로 표시 사이드에 목록표시
		function initMarker() {
			var str = "";
			for (var i = 0; i < course.length; i++) {

				var marker = new google.maps.Marker({
					position : course[i],
					title : course[i].title,
					descs : course[i].descs,
					myPos : course[i].data,
					map : map
				});
				markerArr.push(marker);
				markerInfo(marker);
				poly.getPath().push(marker.position);
				addList(course);

			}

			for (var i = 0; i < recommendArr.length; i++) { //추천 마커 생성

				var marker = new google.maps.Marker({
					position : recommendArr[i],
					title : recommendArr[i].title,
					descs : recommendArr[i].descs,
					myPos : recommendArr[i],
					map : map
				});
				markerInfo(marker);
				drawRecPoly(marker);

			}

		}
		function overlapChecker(marker){
			
			var uniq = course.reduce(function(a, b) {
				if (a.indexOf(b) < 0)
					a.push(b);
					return a;
				}, []);
			if (uniq.length == course.length) {
				poly.getPath().push(marker.position);				
			} else {
				course = uniq;
			}
				
		}
		
		function addList(arr){
			
            var str = "";
            $(".sidebar ul").html("");
            for (var i = 0; i < arr.length; i++) {
                (function(arr) {
                    str = "<li class='courseList' data-idx ='"+i+"'><span class='ui-icon ui-icon-arrowthick-2-n-s'></span>" 
                            + course[i].title;
                    str += "</li>";
                    $(".sidebar ul").append(str);
                })(course);
            }
		}
		
		//추천마커 경로 그리기
		function drawRecPoly(marker) {

			google.maps.event.addListener(marker,'click',function() {

				course.push(marker.myPos);
				markerArr.push(this);				
				overlapChecker(marker);				
				addList(course);

			}); //click listener end
		}

		//마커에 info 생성(마커와 같이 만든다)
		function markerInfo(marker) {

			var infoWindow = new google.maps.InfoWindow;
			google.maps.event.addListener(marker, 'mouseover', function() {

				var str = "<div><strong>"
				str += marker.title;
				str += "</strong>";
				str += "<br><text>" + marker.descs;
				str += "</text></div>";

				infoWindow.setContent(str);
				infoWindow.open(map, marker);

			});

			google.maps.event.addListener(marker, 'mouseout', function() {
				infoWindow.close();

			})

		};
		
		$(function() {
			$("#sortable").sortable({update : function() {

					var liList = $("#sortable").find("li");

					var arr = [];
					//배열에 idx집어넣기
					for (var i = 0; i < liList.length; i++) {

						arr.push($(liList[i]).attr("data-idx"));

					}

					var temp = [];
					var tempCourse = [];

					for (var i = 0; i < liList.length; i++) {

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

		function reArrangeIdx() {

			var liList = $("#sortable").find("li");

			var arr = [];

			for (var i = 0; i < liList.length; i++) {

				$(liList[i]).attr("data-idx", i);

			}
		}

		function redrawMarker(arr) {
			//이전 마커 및 경로 지우기
			for (var i = 0; i < markerArr.length; i++) {

				markerArr[i].setMap(null);
				poly.getPath().pop(arr[i].position);

			}
			//마인드맵 마커 및 경로 생성
			for (var i = 0; i < arr.length; i++) { 

				arr[i].setMap(map);
				poly.getPath().push(arr[i].position); //경로 그리기  	
			}

		}
	</script>

</body>
<script async defer
	src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCIdmqOHKEfF4mfn6EXtuLeeP2-h3yJr6A&callback=initMap">
	
</script>
</html>