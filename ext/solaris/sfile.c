#include <ruby.h>
#include <rubyio.h>
#include <sys/acl.h>
#include <sys/param.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <sfile.h>

/*
 * call-seq:
 *    File.acl_count(file_name)
 *
 * Returns the number of ACL entries for +file_name+. Returns 0 if +file_name+
 * is a trivial file.
 */
static VALUE acl_count(VALUE klass, VALUE v_path){
  int num_acls = 0;
  char pathp[PATH_MAX];

  SafeStringValue(v_path);

  if(strlcpy(pathp, StringValuePtr(v_path), PATH_MAX) >= PATH_MAX)
    rb_raise(rb_eArgError, "path length exceeds limit of: %i", PATH_MAX);

  if((num_acls = acl(pathp, GETACLCNT, 0, NULL)) == -1)
    rb_sys_fail(0);

  if(num_acls == MIN_ACL_ENTRIES)
    num_acls = 0;

  return INT2FIX(num_acls);
}

/*
 * call-seq:
 *    File#acl_count
 *
 * Returns the number of ACL entries for the current handle. Returns 0 if
 * the file is a trivial file.
 */
static VALUE acl_icount(VALUE self){
  int num_acls = 0;
  int fd = FIX2INT(rb_funcall(self, rb_intern("fileno"), 0, 0));

  if((num_acls = facl(fd, GETACLCNT, 0, NULL)) == -1)
    rb_sys_fail(0);

  if(num_acls == MIN_ACL_ENTRIES)
    num_acls = 0;

  return INT2FIX(num_acls);
}

/*
 * call-seq:
 *    File.acl_read(file_name)
 *
 * Returns an array of ACLStruct's that contain three members each:
 *
 * - acl_type (String)
 * - acl_id   (Integer)
 * - acl_perm (Integer)
 *
 * Returns nil if +file_name+ is a trivial file.
 */
static VALUE acl_read(VALUE klass, VALUE v_path){
  int num_acls = 0;
  char pathp[PATH_MAX];
  VALUE v_array = Qnil;
  int i;

  SafeStringValue(v_path);

  if(strlcpy(pathp, StringValuePtr(v_path), PATH_MAX) >= PATH_MAX)
    rb_raise(rb_eArgError, "path length exceeds limit of: %i", PATH_MAX);

  if((num_acls = acl(pathp, GETACLCNT, 0, NULL)) == -1)
    rb_sys_fail(0);

  if(num_acls != MIN_ACL_ENTRIES){
    aclent_t* acl_buf;
    v_array = rb_ary_new();

    if((acl_buf = malloc(sizeof(aclent_t) * num_acls) ) == NULL)
      rb_sys_fail(0);

    if(acl(pathp, GETACL, num_acls, acl_buf) != num_acls)
      rb_sys_fail(0);

    for(i = 0; i < num_acls; i++){
      rb_ary_push(v_array,
        rb_struct_new(sACLStruct,
          acl_type_string(acl_buf[i].a_type),
          INT2FIX(acl_buf[i].a_id),
          INT2FIX(acl_buf[i].a_perm)
        )
       );
    }

    free(acl_buf);
  }

  return v_array;
}

/*
 * call-seq:
 *    File#acl_read
 *
 * Returns an array of ACLStruct's that contain three members each:
 *
 * - acl_type (String)
 * - acl_id   (Integer)
 * - acl_perm (Integer)
 *
 * Returns nil if the file is a trivial file.
 */
static VALUE acl_iread(VALUE self){
  int i;
  int num_acls = 0;
  int fd = FIX2INT(rb_funcall(self, rb_intern("fileno"), 0, 0));
  VALUE v_array = Qnil;

  if((num_acls = facl(fd, GETACLCNT, 0, NULL)) == -1)
    rb_sys_fail(0);

  if(num_acls != MIN_ACL_ENTRIES){
    aclent_t* acl_buf;
    v_array = rb_ary_new();

    if((acl_buf = malloc(sizeof(aclent_t) * num_acls) ) == NULL)
      rb_sys_fail(0);

    if(facl(fd, GETACL, num_acls, acl_buf) != num_acls)
      rb_sys_fail(0);

    for(i = 0; i < num_acls; i++){
      rb_ary_push(v_array,
        rb_struct_new(sACLStruct,
          acl_type_string(acl_buf[i].a_type),
          INT2FIX(acl_buf[i].a_id),
          INT2FIX(acl_buf[i].a_perm)
        )
      );
    }

    free(acl_buf);
  }

  return v_array;
}

/*
 * call-seq:
 *    File.acl_read_text(file_name)
 * 
 * Returns a textual representation of the ACL for +file_name+. If +file_name+
 * is a trivial file, nil is returned.
 */
static VALUE acl_read_text(VALUE klass, VALUE v_path){
  aclent_t* acl_buf;
  int num_acls = 0;
  char* acl_text;
  char pathp[PATH_MAX];
  VALUE v_text = Qnil;

  SafeStringValue(v_path);

  if(strlcpy(pathp, StringValuePtr(v_path), PATH_MAX) >= PATH_MAX)
    rb_raise(rb_eArgError, "path length exceeds limit of: %i", PATH_MAX);

  if((num_acls = acl(pathp, GETACLCNT, 0, NULL)) == -1)
    rb_sys_fail(0);

  if(num_acls != MIN_ACL_ENTRIES){
    if((acl_buf = malloc(sizeof(aclent_t) * num_acls) ) == NULL)
      rb_sys_fail(0);

    if(acl(pathp, GETACL, num_acls, acl_buf) != num_acls)
      rb_sys_fail(0);

    acl_text = acltotext(acl_buf, num_acls);
      
    free(acl_buf);
    v_text = rb_str_new2(acl_text);
  }

  return v_text;
}

/*
 * call-seq:
 *    File.acl_write_text(file_name, acl_text)
 *
 * Sets the ACL for +file_name+ using +acl_text+. The +acl_text+ argument is a
 * human readable ACL text String.
 *
 * If +acl_text+ is invalid then a Solaris::File::Error is raised, and in most
 * cases the offending entry number will be identified.
 */
static VALUE acl_write_text(VALUE klass, VALUE v_path, VALUE v_text){
  aclent_t* acl_buf;
  int num_acls, which, rv;
  char pathp[PATH_MAX];
  char* acl_text = StringValuePtr(v_text);

  SafeStringValue(v_path);
  SafeStringValue(v_text);

  if(strlcpy(pathp, StringValuePtr(v_path), PATH_MAX) >= PATH_MAX)
    rb_raise(rb_eArgError, "path length exceeds limit of: %i", PATH_MAX);

  if((acl_buf = aclfromtext(acl_text, &num_acls)) == NULL)
    rb_raise(cSolarisFileError, "invalid ACL text");

  rv = aclcheck(acl_buf, num_acls, &which);
  do_acl_check(rv, which);

  if(acl(pathp, SETACL, num_acls, acl_buf) == -1){
    free(acl_text);
    rb_sys_fail(0);
  }

  free(acl_text);
  free(acl_buf);

  return klass;
}

/*
 * call-seq:
 *    File.resolvepath(path)
 *
 * Resolves all symbolic links in +path+.  All "." components are removed, as
 * well as all nonleading ".." components and their preceding directory
 * component.  If leading ".." components resolve to the root directory, they
 * are replaced by "/".
 */
static VALUE solaris_resolvepath(VALUE klass, VALUE v_path){
  char pathp[PATH_MAX];

  SafeStringValue(v_path);
  memset(pathp, 0, PATH_MAX);

  if(resolvepath(StringValuePtr(v_path), pathp, PATH_MAX) == -1)
    rb_sys_fail(0);

  return rb_str_new2(pathp);
}

/*
 * call-seq:
 *    File.realpath(path)
 *
 * Resolves all symbolic links in +path+. Resolves to an absolute pathname
 * where possible.
 *
 * The difference between this method and File.resolvepath is that this method
 * will resolve to an absolute pathname where possible.
 */
static VALUE solaris_realpath(VALUE klass, VALUE v_path){
  char pathp[PATH_MAX];

  SafeStringValue(v_path);

  if(realpath(StringValuePtr(v_path), pathp) == NULL)
    rb_sys_fail(0);

  return rb_str_new2(pathp);
}

/* Instance Methods */

/*
 * call-seq:
 *    File#acl_write_text(acl_text)
 *
 * Sets the ACL for the file using +acl_text+.  The +acl_text+ argument is a
 * human readable ACL text String.
 *
 * If +acl_text+ is invalid then a File::Solaris::Error is raised, and in most
 * cases the offending entry number will be identified.
 */
static VALUE acl_iwrite_text(VALUE self, VALUE v_text){
  aclent_t* acl_buf;
  int num_acls, which, rv;
  char* acl_text = StringValuePtr(v_text);
  int fd = FIX2INT(rb_funcall(self, rb_intern("fileno"), 0, 0));

  SafeStringValue(v_text);

  if((acl_buf = aclfromtext(acl_text, &num_acls)) == NULL)
    rb_raise(cSolarisFileError, "invalid ACL text");

  rv = aclcheck(acl_buf, num_acls, &which);
  do_acl_check(rv, which);

  if(facl(fd, SETACL, num_acls, acl_buf) == -1){
    free(acl_text);
    rb_sys_fail(0);
  }

  free(acl_text);
  free(acl_buf);

  return self;
}


/*
 * call-seq:
 *    File#acl_read_text
 * 
 * Returns a textual representation of the ACL for the current handle.  If
 * the file is a trivial file, nil is returned.
 */
static VALUE acl_iread_text(VALUE self){
  char* acl_text;
  int num_acls = 0;
  int fd = FIX2INT(rb_funcall(self,rb_intern("fileno"),0,0));
  VALUE v_text = Qnil;

  if((num_acls = facl(fd,GETACLCNT,0,NULL)) == -1)
    rb_sys_fail(0);

  if(num_acls != MIN_ACL_ENTRIES){
    aclent_t* acl_buf;

    if((acl_buf = malloc(sizeof(aclent_t) * num_acls) ) == NULL)
      rb_sys_fail(0);

    if(facl(fd, GETACL, num_acls, acl_buf) != num_acls)
      rb_sys_fail(0);

    acl_text = acltotext(acl_buf,num_acls);
      
    free(acl_buf);
    v_text = rb_str_new2(acl_text); 
  }

  return v_text;
}

/*
 * call-seq:
 *    File.trivial?(file_name)
 *
 * Returns true if +file_name+ is a trivial file, i.e. has no additional ACL
 * entries. Otherwise, it returns false.
 */
static VALUE acl_is_trivial(VALUE klass, VALUE v_path){
  char pathp[PATH_MAX];
  int num_acls = 0;
  VALUE v_bool = Qfalse;

  SafeStringValue(v_path);

  if(strlcpy(pathp, StringValuePtr(v_path), PATH_MAX) >= PATH_MAX)
    rb_raise(rb_eArgError, "path length exceeds limit of: %i", PATH_MAX);

  if((num_acls = acl(pathp, GETACLCNT, 0, NULL)) == -1)
    rb_sys_fail(0);

  if(num_acls == MIN_ACL_ENTRIES)
    v_bool = Qtrue;

  return v_bool;
}

/*
 * call-seq:
 *    File#trivial?
 *
 * Returns true if the current file is a trivial file, i.e. has no additional
 * ACL entries.  Otherwise, it returns false.
 */
static VALUE acl_itrivial(VALUE self){
  int fd = FIX2INT(rb_funcall(self, rb_intern("fileno"), 0, 0));
  int num_acls = 0;
  VALUE v_bool = Qfalse;

  if((num_acls = facl(fd, GETACLCNT, 0, NULL)) == -1)
    rb_sys_fail(0);

  if(num_acls == MIN_ACL_ENTRIES)
    v_bool = Qtrue;

  return v_bool;
}

/* File::Stat Additions */

/*
 * call-seq:
 *    statfile.door?
 *
 * Returns true if +statfile+ is a door, false otherwise.
 */
static VALUE solaris_stat_is_door(VALUE self){
  VALUE v_bool = Qtrue;
  int mode = FIX2INT(rb_funcall(self, rb_intern("mode"), 0, 0));

  if(S_ISDOOR(mode) == 0)
    v_bool = Qfalse;

  return v_bool;
}

/*
 * call-seq:
 *   statfile.ftype
 *
 * Returns the file type. This method is identical to the core Ruby method
 * except that it returns "door" if the file is a door file.
 */
static VALUE solaris_stat_ftype(VALUE self){
  int mode = FIX2INT(rb_funcall(self, rb_intern("mode"), 0, 0));

  if(S_ISDOOR(mode))
    return rb_str_new2("door");
  else
    return rb_funcall(self, rb_intern("old_ftype"), 0, 0);
}

/*
 * call-seq:
 *   File.door?(file)
 *
 * Returns true if +file+ is a door file, false otherwise.
 */
static VALUE solaris_file_is_door(VALUE klass, VALUE v_file){
  VALUE v_stat = rb_funcall(rb_cStat, rb_intern("new"), 1, v_file);
  return solaris_stat_is_door(v_stat);
}

/*
 * call-seq:
 *   File.ftype(file)
 *
 * The File.ftype method was modified so that 'door' is returned if the
 * +file+ is a door file.
 */
static VALUE solaris_file_ftype(VALUE klass, VALUE v_file){
  VALUE v_stat = rb_funcall(rb_cStat, rb_intern("new"), 1, v_file);
  return solaris_stat_ftype(v_stat);
}

/*
 * Adds ACL support for the File class on Solaris
 */
void Init_file(){
  /* Error raised if an error occurs when reading or writing ACL properties */
  cSolarisFileError = rb_define_class_under(
    rb_cFile,
    "SolarisError",
    rb_eStandardError
  );

  // Singleton Methods

  rb_define_singleton_method(rb_cFile, "acl_count", acl_count, 1);
  rb_define_singleton_method(rb_cFile, "acl_read", acl_read, 1);
  rb_define_singleton_method(rb_cFile, "acl_read_text", acl_read_text, 1);
  rb_define_singleton_method(rb_cFile, "acl_write_text", acl_write_text, 2);
  rb_define_singleton_method(rb_cFile, "door?", solaris_file_is_door, 1);
  rb_define_singleton_method(rb_cFile, "ftype", solaris_file_ftype, 1);
  rb_define_singleton_method(rb_cFile, "realpath", solaris_realpath, 1);
  rb_define_singleton_method(rb_cFile, "resolvepath", solaris_resolvepath, 1);
  rb_define_singleton_method(rb_cFile, "trivial?", acl_is_trivial, 1);

  // File Instance Methods

  rb_define_method(rb_cFile, "acl_count", acl_icount, 0);
  rb_define_method(rb_cFile, "acl_read", acl_iread, 0);
  rb_define_method(rb_cFile, "acl_read_text", acl_iread_text, 0);
  rb_define_method(rb_cFile, "acl_write_text", acl_iwrite_text, 1);
  rb_define_method(rb_cFile, "trivial?", acl_itrivial, 0);

  // File::Stat Instance Methods

  rb_define_alias(rb_cStat, "old_ftype", "ftype");
  rb_define_method(rb_cStat, "door?", solaris_stat_is_door, 0);
  rb_define_method(rb_cStat, "ftype", solaris_stat_ftype, 0);

  // Structs

  sACLStruct = rb_struct_define("ACLStruct",
    "acl_type", "acl_id", "acl_perm", NULL
  );

  /* 0.3.5: The version of the solaris-file library */
  rb_define_const(rb_cFile, "SOLARIS_VERSION", rb_str_new2(SOLARIS_VERSION));
}
