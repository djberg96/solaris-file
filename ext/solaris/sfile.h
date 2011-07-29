#define SOLARIS_VERSION "0.3.7"
#define MAX_STRING 512

VALUE cSolarisFileError;
VALUE sACLStruct;

/*
 * Converts a numeric ACL type into a human readable string.
 */
static VALUE acl_type_string(int acl_type){
  VALUE v_acl_type;

  switch(acl_type){
    case USER: case USER_OBJ:
      v_acl_type = rb_str_new2("user");
      break;
    case GROUP: case GROUP_OBJ:
      v_acl_type = rb_str_new2("group");
      break;
    case OTHER_OBJ:
      v_acl_type = rb_str_new2("other");
      break;
    case CLASS_OBJ:
      v_acl_type = rb_str_new2("mask");
      break;
    case DEF_USER: case DEF_USER_OBJ:
      v_acl_type = rb_str_new2("defaultuser");
      break;
    case DEF_GROUP: case DEF_GROUP_OBJ:
      v_acl_type = rb_str_new2("defaultgroup");
      break;
    case DEF_OTHER_OBJ:
      v_acl_type = rb_str_new2("defaultother");
      break;
    case DEF_CLASS_OBJ:
      v_acl_type = rb_str_new2("defaultmask");
      break;
    default:
      v_acl_type = rb_str_new2("unknown");
  }

  return v_acl_type;
}

/*
 * Helper function used by the acl_write_text class and instance methods.
 */
void do_acl_check(int aclcheck_val, int which){
   char err[MAX_STRING];

  switch(aclcheck_val){
    case 0:
      break; // Nothing wrong
    case USER_ERROR:
      sprintf(err,"Invalid ACL entry: %i; Multiple user entries", which);
      rb_raise(cSolarisFileError, err);
      break;
    case GRP_ERROR:
      sprintf(err,"Invalid ACL entry: %i; Multiple group entries", which);
      rb_raise(cSolarisFileError, err);
      break;
    case OTHER_ERROR:
      sprintf(err,"Invalid ACL entry: %i; Multiple other entries", which);
      rb_raise(cSolarisFileError, err);
      break;
    case CLASS_ERROR:
      sprintf(err,"Invalid ACL entry: %i; Multiple mask entries", which);
      rb_raise(cSolarisFileError, err);
      break;
    case DUPLICATE_ERROR:
      sprintf(err,"Invalid ACL entry: %i; Multiple user or group entries", which);
      rb_raise(cSolarisFileError, err);
      break;
    case ENTRY_ERROR:
      sprintf(err,"Invalid ACL entry: %i; Invalid entry type", which);
      rb_raise(cSolarisFileError, err);
      break;
    case MISS_ERROR:
      rb_raise(cSolarisFileError, "Missing ACL entries");
      break;
    case MEM_ERROR:
      rb_raise(cSolarisFileError, "Out of memory!");
      break;
    default:
      rb_raise(cSolarisFileError, "Unknown error");
  };
}
