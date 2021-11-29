package com.puppycrawl.tools.checkstyle;

import org.apache.commons.logging.Log;

import com.puppycrawl.tools.checkstyle.api.BeforeExecutionFileFilterSet;
import com.puppycrawl.tools.checkstyle.api.SeverityLevel;
import com.puppycrawl.tools.checkstyle.api.SeverityLevelCounter;

public class ErrorCheck {

	public static final String EXCEPTION_MSG = "general.exception";
/** Logger for Checker. */

	 Log log;
	 
	 /** Maintains error count. */
	  SeverityLevelCounter counter = new SeverityLevelCounter(
	            SeverityLevel.ERROR);
	  public final BeforeExecutionFileFilterSet beforeExecutionFileFilters =
	            new BeforeExecutionFileFilterSet();
	  public SeverityLevel severity = SeverityLevel.ERROR;
}
