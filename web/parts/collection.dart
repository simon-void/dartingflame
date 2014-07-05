part of dartingflame;

class BucketMap<T> extends Object with  MapMixin<int,T>
{
  final List<T> indexedElements;
  final T neutralElement;
  
  BucketMap(int bucketSize): this.filled(bucketSize, null);
    
  BucketMap.filled(int bucketSize, T neutralElement):
    indexedElements = new List<T>.filled(bucketSize, neutralElement),
    this.neutralElement = neutralElement;
    
  @override
  T operator [] (int index)=>indexedElements[index];
  
  @override
  void operator []= (int index,T element) {
    indexedElements[index] = element;
  }
  
  @override
  T remove(int index) {
    T element = indexedElements[index];
    indexedElements[index] = neutralElement;
    return element;
  }
  
  @override
  void clear() {
    for(int i=0; i<indexedElements.length; i++ ) {
      indexedElements[i] = neutralElement;
    }
  }
  
  @override
  Iterable<int> get keys {
    List<int> keys = new List<int>();
    for(int i=0; i<indexedElements.length; i++ ) {
      if(indexedElements[i]!=neutralElement) {
        keys.add(i);
      }
    }
    return keys;
  }
  
  @override
  Iterable<T> get values {
    List<T> values = new List<T>();
    for(int i=0; i<indexedElements.length; i++ ) {
      if(indexedElements[i]!=neutralElement) {
        values.add(indexedElements[i]);
      }
    }
    return values;
  }
  
  @override
  bool containsKey(int key)=>indexedElements[key]!=neutralElement;
}