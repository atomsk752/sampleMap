package org.injae.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Select;
import org.injae.domain.StoreVO;

public interface SampleMapper {
	
	@Select("select * from tbl_mapex")
	public List<StoreVO> getList();

	@Select("select * from tbl_mapex2")
	public List<StoreVO> getList2();
}

