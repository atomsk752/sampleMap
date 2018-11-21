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
    $(function () {
        $("#sortable").sortable({
            update: function() {
            	
                console.log("ddddd");
                
                var liList = $("#sortable").find("li");
                
                console.log(liList);
                
                var arr = [];
                
                for(var i = 0; i < liList.length; i++){
                	
                	arr.push($(liList[i]).attr("data-idx"));
                	
                }
                console.log(arr);
                
                var temp = [];
                
                for(var i = 0; i < liList.length; i++){
                	
                	//console.log(arr[i]);
                	
                	temp.push(markerArr[arr[i]]);
                	
                }
                
                markerArr = temp;
                
                //console.log(markerArr);
                
                redrawMarker(markerArr);
            }
        });
        // $("#sortable").disableSelection();
      });
    
    function redrawMarker(arr){
    	
    	console.log(map);
    	
    	//remove all markers 
    	for(var i = 0;i < markerArr.length; i++){
    		
    		markerArr[i].setMap(null);
    		poly.getPath().pop(arr[i].position);
    		
    	}
    	
    	//draw re arragned markers
    	
    	 for (var i = 0; i < arr.length; i++) { //마인드맵 마커 생성
            
    		 arr[i].setMap(map);
    		 poly.getPath().push(arr[i].position); //경로 그리기  	
         }
    	
    	
    }
    
    
        var map;
        var mindMapArr = new Array();
        var recommendArr = new Array();
        var course = new Array();
        var markerArr = new Array();
       
        
        $(document).ready(function() {
            
            
            $.getJSON("/sample/dataEx.json", function(json1) {
                
                $(json1).each(function(key, data) {
                    
                    mindMapArr.push(data);
                    course.push(data);
                    
                }); // end each
                
                
                
            }); // end getJSON
            
          
            $.getJSON("/sample/dataEx2.json", function(json2) {
                
                $.each(json2, function(key, data) {
                    
                    recommendArr.push(data);
                    
                }); // end each
            }); // end getJSON
            
            
            
            
        });
        
        
        var poly;
        
        function initMap() {
            
            map = new google.maps.Map(document.getElementById('map'), {
                center : course[course.length - 1],
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
            var str = "";
            for (var i = 0; i < course.length; i++) { //마인드맵 마커 생성
            	
            	course[i]['key'] = i;
            	
                var marker = new google.maps.Marker({
                    position : course[i],
                    title : course[i].title,
                    descs : course[i].descs,
                    map : map
                });
                
                markerArr.push(marker);
                
                str += "<li class='courseList' data-idx ='"+i+"' data-course='" + JSON.stringify(course[i]) 
                + "'><span class='ui-icon ui-icon-arrowthick-2-n-s'></span>" + course[i].title;
                str += "</li>";
                
                $("#sortable").html(str);

                var infoWindow = new google.maps.InfoWindow;
                
                poly.getPath().push(marker.position); //경로 그리기
                
                 (function(target) {//마커info 표시
                        google.maps.event.addListener(marker, 'mouseover', function(){
                            
                            var infowincontent = document.createElement('div');
                            var strong = document.createElement('strong');
                            
                            strong.textContent = target.title;
                            infowincontent.appendChild(strong);
                            infowincontent.appendChild(document.createElement('br'));
                            
                            var text = document.createElement('text');
                            
                            text.textContent = target.descs;
                            infowincontent.appendChild(text); 
                            
                            infoWindow.setContent(infowincontent);
                            infoWindow.open(map, target);
                            
                        });
                 
                    })(marker);
                
                    google.maps.event.addListener(marker, 'mouseout', function(){
                        infoWindow.close();
                        
                    })              

            }
            var str2 ="";
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
                           
                        var uniq = course.reduce(function(a, b) {//마커클릭시 course배열에서 중복제거
                            //console.log(a.indexOf(b));
                            if (a.indexOf(b) < 0)
                                a.push(b);
                            
                            return a;
                        }, []);
                        
						markerArr.push(this);
						console.log(markerArr);
                        if (uniq.length == course.length) { //폴리 연결시 중복체크
                            
                            poly.getPath().push(target.position);
                            
                            course = uniq;
                            
                            var idx =  $("#sortable li").length;
                            
                            str += "<li class='courseList' data-idx ='"+idx+"' data-course='" + course[course.length-1] 
                            + "'><span class='ui-icon ui-icon-arrowthick-2-n-s'></span>" + course[course.length-1].title;
                            str += "</li>";
                            $(".sidebar ul").html(str);
                            

                            
                        }else{
                        
                        course = uniq;
                        

                        }
                        

                        //console.log(course[course.length-1]);
                        //console.log(course);
                        
                        

                    });
             
                })(marker);
                
                
                
                var infoWindow = new google.maps.InfoWindow;
                
                 (function(target) {//마커info 표시
                     
                        google.maps.event.addListener(marker, 'mouseover', function(){
                            
                            var infowincontent = document.createElement('div');
                            var strong = document.createElement('strong');
                            
                            strong.textContent = target.title;
                            infowincontent.appendChild(strong);
                            infowincontent.appendChild(document.createElement('br'));
                            
                            var text = document.createElement('text');
                            
                            text.textContent = target.descs;
                            infowincontent.appendChild(text); 
                            //console.log(target);
                            
                            infoWindow.setContent(infowincontent);
                            infoWindow.open(map, target);
                        });
                 
                    })(marker); //마커 info 표시 끝
                 
                    google.maps.event.addListener(marker, 'mouseout', function(){
                        infoWindow.close();
                    })      
                    

            }//추천마커 생성 끝
            
            
           
            
            poly.setMap(map);
        }
    </script>
    <script async defer
        src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCIdmqOHKEfF4mfn6EXtuLeeP2-h3yJr6A&callback=initMap">
        
    </script>
</body>
</html>