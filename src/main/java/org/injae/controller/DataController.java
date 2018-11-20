package org.injae.controller;

import java.util.List;

import org.injae.domain.StoreVO;
import org.injae.mapper.SampleMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.Setter;
import lombok.extern.log4j.Log4j;

@RestController
@RequestMapping("/sample/*")
@Log4j
public class DataController {
	
	@Setter(onMethod_ = @Autowired)
	private SampleMapper mapper;
	
	@GetMapping(value = "/dataEx", produces= {MediaType.APPLICATION_XML_VALUE, MediaType.APPLICATION_JSON_UTF8_VALUE})
	public ResponseEntity<List<StoreVO>> mapEx() {
		log.info("data.......");
		return new ResponseEntity<>(mapper.getList(), HttpStatus.OK);
	}
	
	@GetMapping(value = "/dataEx2", produces= {MediaType.APPLICATION_XML_VALUE, MediaType.APPLICATION_JSON_UTF8_VALUE})
	public ResponseEntity<List<StoreVO>> mapEx2() {
		log.info("data.......");
		return new ResponseEntity<>(mapper.getList2(), HttpStatus.OK);
	}
	
}
