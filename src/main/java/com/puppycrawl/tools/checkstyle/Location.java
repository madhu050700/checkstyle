package com.puppycrawl.tools.checkstyle;

import java.util.Locale;

public class Location {

	/** Locale country to report messages . **/
    public String localeCountry = Locale.getDefault().getCountry();
    /** Locale language to report messages . **/
    public String localeLanguage = Locale.getDefault().getLanguage();

}
