package org.injae.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/sample/*")
public class MapController {
	
	@GetMapping("/mapEx")
	public void mapEx()	{
	}

}
