require 'formula'

class Macruby < Formula
  version '0.10'
  head 'git://github.com/MacRuby/MacRuby.git'
  url 'https://nodeload.github.com/MacRuby/MacRuby/tarball/0.10'
  md5 '3716da78ec7ff4345bfd1bdaffae5b11'
  homepage 'http://www.macruby.org'

  depends_on 'llvm'

  def patches
    # Until 0.11 is released, this patch is required to build MacRuby on Lion
    DATA unless ARGV.build_head?
  end

  def install
    framework = prefix.join('Library/Framework/')
    framework.mkpath
    rake_args = "framework_instdir=#{framework}"
    system "/usr/bin/rake all #{rake_args}"
    system "/usr/bin/rake install #{rake_args}"
  end

  def test
    system "/usr/bin/rake spec"
  end
end
__END__
diff --git a/ext/iconv/extconf.rb b/ext/iconv/extconf.rb
index e97ad60..6f454be 100644
--- a/ext/iconv/extconf.rb
+++ b/ext/iconv/extconf.rb
@@ -43,7 +43,7 @@ if have_func("iconv", "iconv.h") or
     $cleanfiles << wrapper
   end
   $INCFLAGS << ' -I../..'
-  $INCFLAGS << ' -I../../icu-1060' if `sw_vers -productVersion`.to_f <= 10.6
+  $INCFLAGS << ' -I../../icu-1060' if `sw_vers -productVersion`.to_f <= 10.7
   create_makefile("iconv")
   if conf
     open("Makefile", "a") do |mf|
diff --git a/ext/ripper/extconf.rb b/ext/ripper/extconf.rb
index 4504c66..4c0ed9b 100644
--- a/ext/ripper/extconf.rb
+++ b/ext/ripper/extconf.rb
@@ -16,7 +16,7 @@ def main
   $defs << '-DRIPPER_DEBUG' if $debug
   $VPATH << '$(topdir)' << '$(top_srcdir)'
   $INCFLAGS << ' -I$(topdir) -I$(top_srcdir) -I$(top_srcdir)/onig'
-  $INCFLAGS << ' -I../../icu-1060' if `sw_vers -productVersion`.to_f <= 10.6
+  $INCFLAGS << ' -I../../icu-1060' if `sw_vers -productVersion`.to_f <= 10.7
   $CFLAGS << ' -std=c99'
   create_makefile 'ripper'
 end
diff --git a/gc.c b/gc.c
index c7af153..f9ba9ba 100644
--- a/gc.c
+++ b/gc.c
@@ -126,11 +126,14 @@ void *
 ruby_xmalloc_ptrs(size_t size)
 {
     int type;
-#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
-    type = AUTO_MEMORY_ALL_POINTERS;
-#else
+//#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
+//#define AUTO_POINTERS_ONLY (1 << 2)
+//#define AUTO_MEMORY_ALL_POINTERS AUTO_POINTERS_ONLY
+//
+//    type = AUTO_MEMORY_ALL_POINTERS;
+//#else
     type = AUTO_MEMORY_SCANNED;
-#endif
+//#endif
     return ruby_xmalloc_memory(size, type);
 }
 
diff --git a/rakelib/builder/options.rb b/rakelib/builder/options.rb
index 3df3e31..686b6b6 100644
--- a/rakelib/builder/options.rb
+++ b/rakelib/builder/options.rb
@@ -173,7 +173,7 @@ class BuilderConfig
     end
     @cxxflags << " -fno-rtti" unless @cxxflags.index("-fno-rtti")
     @dldflags = "-dynamiclib -undefined suppress -flat_namespace -install_name #{INSTALL_NAME} -current_version #{MACRUBY_VERSION} -compatibility_version #{MACRUBY_VERSION} -exported_symbols_list #{EXPORTED_SYMBOLS_LIST}"
-    if `sw_vers -productVersion`.to_f <= 10.6
+    if `sw_vers -productVersion`.to_f <= 10.7
       @cflags << ' -I./icu-1060'
       @cxxflags << ' -I./icu-1060'
     end
diff --git a/instruby.rb b/instruby.rb
index 16af291..4b0768b 100755
--- a/instruby.rb
+++ b/instruby.rb
@@ -490,8 +490,8 @@ if RUBY_FRAMEWORK
     next if bin[0] == '.'
     # Except rb_nibtool & llc!
     next if bin == 'rb_nibtool' or bin == 'llc'
-    link = File.join("../../../", CONFIG['bindir'], bin)
-    link.sub!(/#{install_version}/, 'Current')
+    link = File.join(CONFIG['bindir'], bin)
+    link[link.rindex(install_version), install_version.length] = "Current"
     ln_sfh link, File.join(dest_bin, File.basename(bin))
   end
   # Installing man pages links.
@@ -503,14 +503,14 @@ if RUBY_FRAMEWORK
       mkdir_p File.join(dest_man, File.basename(mandir)), :mode => 0755
       Dir.entries(File.join(with_destdir(CONFIG['mandir']), mandir)).each do |man|
         next if man[0] == '.'
-        link = File.join("../../../../../", CONFIG['mandir'], mandir, man)
-        link.sub!(/#{install_version}/, 'Current')
+        link = File.join(CONFIG['mandir'], mandir)
+        link[link.rindex(install_version), install_version.length] = "Current"
         ln_sfh link, File.join(dest_man, File.basename(mandir), 
	  File.basename(man))
       end
     else
-      link = File.join("../../../../", CONFIG['mandir'], mandir)
-      link.sub!(/#{install_version}/, 'Current')
+      link = File.join(CONFIG['mandir'], mandir)
+      link[link.rindex(install_version), install_version.length] = "Current"
       ln_sfh link, File.join(dest_man, File.basename(mandir))
     end
   end
