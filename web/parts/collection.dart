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
    return indexedElements.where((T element)=>element!=neutralElement);
  }
  
  @override
  bool containsKey(int key)=>indexedElements[key]!=neutralElement;
}

class BucketMapOfList<T> extends Object with  MapMixin<int,List<T>>
{
  final List<List<T>> indexedLists;
    
  BucketMapOfList(int bucketSize):
    indexedLists = new List<List<T>>.generate(bucketSize, (int index)=>new List<T>());
    
  @override
  List<T> operator [] (int index)=>indexedLists[index];
  
  @override
  void operator []= (int index,List<T> element) {
    indexedLists[index] = element;
  }
  
  @override
  List<T> remove(int index) {
    List<T> element = indexedLists[index];
    indexedLists[index] = new List<T>();
    return element;
  }
  
  @override
  void clear() {
    indexedLists.forEach((List<T> list)=>list.clear());
  }
  
  @override
  Iterable<int> get keys {
    List<int> keys = new List<int>();
    for(int i=0; i<indexedLists.length; i++ ) {
      if(indexedLists[i].isNotEmpty) {
        keys.add(i);
      }
    }
    return keys;
  }
  
  @override
  Iterable<List<T>> get values {
    return indexedLists.where((List<T> list)=>list.isNotEmpty);
  }
  
  @override
  bool containsKey(int key)=>indexedLists[key].isNotEmpty;
}