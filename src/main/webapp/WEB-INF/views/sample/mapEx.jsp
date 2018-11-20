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
	height: 500px;
	width: 1000px;
}
/* Optional: Makes the sample page fill the window. */
html, body {
	height: 100%;
	margin: 0;
	padding: 0;
}
</style>
</head>
<body>
	<div id="map"></div>

	<script src="https://code.jquery.com/jquery-1.12.4.js"></script>
	<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>


	<script>
		var map;
		var mindMapArr = new Array();
		var recommendArr = new Array();
		var course = new Array();
		$(document).ready(function() {

			$.getJSON("/sample/dataEx.json", function(json1) {
				$.each(json1, function(key, data) {

					mindMapArr.push(data);
					course.push(data);

		    /*      var infoWindow = new google.maps.InfoWindow;
		            
		            var infowincontent = document.createElement('div');
					var strong = document.createElement('strong');
					strong.textContent = title;
					infowincontent.appendChild(strong);
					infowincontent.appendChild(document.createElement('br'));
					
					var text = document.createElement('text');
					text.textContent = descs;
					infowincontent.appendChild(text); */
					
					
				}); // end each
				console.log(mindMapArr);
			}); // end getJSON

			$.getJSON("/sample/dataEx2.json", function(json2) {
				$.each(json2, function(key, data) {

					recommendArr.push(data);

				}); // end each
				console.log(recommendArr);
			}); // end getJSON

		});
		var poly;

		function initMap() {
			map = new google.maps.Map(document.getElementById('map'), {
				center : mindMapArr[mindMapArr.length - 1],
				zoom : 15,
				minZoom : 13
			//확대 가능한 최소 크기
			});
			poly = new google.maps.Polyline({ //선분 모양 설정
				strokeColor : '#000000',
				strokeOpacity : 1.0,
				strokeWeight : 3
			});
			var path = poly.getPath();
			for (var i = 0; i < mindMapArr.length; i++) { //마인드맵 마커 생성
				var marker = new google.maps.Marker({
					position : mindMapArr[i],
					title : mindMapArr[i].title,
					descs : mindMapArr[i].descs,
					map : map
				});
				var infoWindow = new google.maps.InfoWindow;
				
				poly.getPath().push(marker.position); //경로 그리기
				 (function(target) {
	                    google.maps.event.addListener(marker, 'mouseover', function(){
	                        var infowincontent = document.createElement('div');
	                        var strong = document.createElement('strong');
	                        strong.textContent = target.title;
	                        infowincontent.appendChild(strong);
	                        infowincontent.appendChild(document.createElement('br'));
	                        
	                        var text = document.createElement('text');
	                        text.textContent = target.descs;
	                        infowincontent.appendChild(text); 
	                        console.log(target);
	                        
	                        infoWindow.setContent(infowincontent);
	                        infoWindow.open(map, target);
	                    });
	                })(marker);
	                google.maps.event.addListener(marker, 'mouseout', function(){
	                    infoWindow.close();
	                }) 				
				
			}
			for (var i = 0; i < recommendArr.length; i++) { //추천 마커 생성
				marker = new google.maps.Marker({
					position : recommendArr[i],
					title : recommendArr[i].title,
					descs : recommendArr[i].descs,
					myPos : recommendArr[i],
					map : map
				});
				(function(target) { //마커에 클릭 이벤트, 클릭한 마커를 경로 배열에 추가
					google.maps.event.addListener(target, 'click', function() {


						
						course.push(target.myPos);
						
						poly.getPath().push(target.position);
						
						var uniq = course.reduce(function(a, b){
							if (a.indexOf(b)<0) a.push(b);
							return a;
						},[]);
						course = uniq;
						
						

						console.log(course);
						
					});
				})(marker);
			}
			console.dir(marker);
			poly.setMap(map);
		}
	</script>
	<script async defer
		src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCIdmqOHKEfF4mfn6EXtuLeeP2-h3yJr6A&callback=initMap">
		
	</script>
</body>
</html>