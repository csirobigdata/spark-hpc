#include <stdio.h>
#include <stdlib.h>
#include "JniTransformer.h" 

JNIEXPORT jstring JNICALL Java_JniTransformer_jniTransform
  (JNIEnv * env, jobject self, jstring str)
{
  return str;
}
