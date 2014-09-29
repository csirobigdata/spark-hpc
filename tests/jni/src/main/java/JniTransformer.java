public class JniTransformer {
 
  public String transform(String str){
    return jniTransform(str);
  }
  private native String jniTransform(String str);  
}
