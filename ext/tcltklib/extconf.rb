# extconf.rb for tcltklib

require 'mkmf'

have_library("socket", "socket")
have_library("nsl", "gethostbyname")
have_library("dl", "dlopen")
have_library("m", "log") 

$includes = []
def search_header(include, *path)
  pwd = Dir.getwd
  begin
    for i in path.reverse!
      dir = Dir[i]
      for path in dir
	Dir.chdir path
	files = Dir[include]
	if files.size > 0
	  unless $includes.include? path
	    $includes << path
	  end
	  return
	end
      end
    end
  ensure
    Dir.chdir pwd
  end
end

search_header("tcl.h",
	      "/usr/include/tcl*",
	      "/usr/include",
	      "/usr/local/include/tcl*",
	      "/usr/local/include")
search_header("tk.h",
	      "/usr/include/tk*",
	      "/usr/include",
	      "/usr/local/include/tk*",
	      "/usr/local/include")
search_header("X11/Xlib.h",
	      "/usr/include/X11*",
	      "/usr/include",
	      "/usr/openwin/include",
	      "/usr/X11*/include")

$CFLAGS = "-Wall " + $includes.collect{|path| "-I" + path}.join(" ")

$libraries = []
def search_lib(file, func, *path)
  for i in path.reverse!
    dir = Dir[i]
    for path in dir
      $LDFLAGS = $libraries.collect{|p| "-L" + p}.join(" ") + " -L" + path
      files = Dir[path+"/"+file]
      if files.size > 0
	for lib in files
	  lib = File::basename(lib)
	  lib.sub!(/^lib/, '')
	  lib.sub!(/\.(a|so)$/, '')
	  if have_library(lib, func)
	    unless $libraries.include? path
	      $libraries << path
	    end
	    return TRUE
	  end
	end
      end
    end
  end
  return FALSE;
end

if have_header("tcl.h") && have_header("tk.h") &&
    search_lib("libX11.{a,so}", "XOpenDisplay",
	       "/usr/lib", "/usr/openwin/lib", "/usr/X11*/lib") &&
    search_lib("libtcl{,7*,8*}.{a,so}", "Tcl_FindExecutable",
	       "/usr/lib", "/usr/local/lib") &&
    search_lib("libtk{,4*,8*}.{a,so}", "Tk_Init",
	       "/usr/lib", "/usr/local/lib")
  $LDFLAGS = $libraries.collect{|path| "-L" + path}.join(" ")
  create_makefile("tcltklib")
end
