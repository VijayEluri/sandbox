package sandbox;

import java.lang.ref.ReferenceQueue;
import java.lang.ref.PhantomReference;

/**
 * An example of ThreadLocal leak which causes a class loader leak.
 *
 * You can fix the leak by modifying 1 line in the class. Of course the change is not in the main() method.
 */
public class ThreadLocalKeyValue {

    private ThreadLocal tl = new ThreadLocal();

    public void add(Object key, Object value) {
        tl.set(new KeyValuePair(key, value));
    }

    public Object getKey() {
        return ((KeyValuePair)tl.get()).key;
    }

    public Object getValue() {
        return ((KeyValuePair)tl.get()).value;
    }

    private class KeyValuePair {
        public Object key;
        public Object value;
        public KeyValuePair(Object key, Object value) {
            this.key = key;
            this.value = value;
        }
    }

    public static void main(String[] args) throws Exception {
        ThreadLocalKeyValue target = new ThreadLocalKeyValue();
        ReferenceQueue queue = new ReferenceQueue();
        PhantomReference ref = new PhantomReference(target, queue);

        target.add("foo", "bar");
        target = null;

        System.gc();
        System.out.println("Released?: " + ref.isEnqueued());
   }
}
