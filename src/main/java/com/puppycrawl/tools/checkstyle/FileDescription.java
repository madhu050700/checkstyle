package com.puppycrawl.tools.checkstyle;

import java.io.File;
import java.nio.file.Path;
import java.util.List;

import com.puppycrawl.tools.checkstyle.Main.OutputFormat;
import com.puppycrawl.tools.checkstyle.utils.CommonUtil;

import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

public class FileDescription {

	/** Width of CLI help option. */
    public int HELP_WIDTH = 100;

    /** The default number of threads to use for checker and the tree walker. */
     public int THREAD_COUNT = 1;

    /** Name for the moduleConfig attribute 'tabWidth'. */
     String ATTRIB_TAB_WIDTH_NAME = "tabWidth";

    /** Default output format. */
     OutputFormat DEFAULT_OUTPUT_FORMAT = OutputFormat.PLAIN;

    /** Option name for output format. */
   public String OUTPUT_FORMAT_OPTION = "-f";
   
   /** List of file to validate. */
   public @Parameters(arity = "1..*", description = "One or more source files to verify") List<File> files;
   
   /** Config file location. */
   @Option(names = "-c", description = "Specifies the location of the file that defines"
           + " the configuration modules. The location can either be a filesystem location"
           + ", or a name passed to the ClassLoader.getResource() method.") String configurationFile;
   /** Output file location. */
   @Option(names = "-o", description = "Sets the output file. Defaults to stdout.")
  public Path outputPath;

   /** Properties file location. */
   @Option(names = "-p", description = "Sets the property files to load.")
   public File propertiesFile;

   /** LineNo and columnNo for the suppression. */
   @Option(names = "-s",
           description = "Prints xpath suppressions at the file's line and column position. "
                   + "Argument is the line and column number (separated by a : ) in the file "
                   + "that the suppression should be generated for. The option cannot be used "
                   + "with other options and requires exactly one file to run on to be "
                   + "specified. ATTENTION: generated result will have few queries, joined "
                   + "by pipe(|). Together they will match all AST nodes on "
                   + "specified line and column. You need to choose only one and recheck "
                   + "that it works. Usage of all of them is also ok, but might result in "
                   + "undesirable matching and suppress other issues.")
   public String suppressionLineColumnNumber;

   /**
    * Tab character length.
    * Suppression: CanBeFinal - we use picocli and it use  reflection to manage such fields
    *
    * @noinspection CanBeFinal
    */
   @Option(names = {"-w", "--tabWidth"},
           description = "Sets the length of the tab character. "
           + "Used only with -s option. Default value is ${DEFAULT-VALUE}.")
   public int tabWidth = CommonUtil.DEFAULT_TAB_WIDTH;

   
  







}
