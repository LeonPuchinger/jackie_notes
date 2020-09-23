/// Wrapper to lock in objects to make them temporarily immutable.
/// Any changes made during locked state are applied when unlocking.
class Cabinet<T> {
  T _value, _queue;
  bool _locked = false;

  Cabinet();

  Cabinet.fromValue(this._value);

  lock() => _locked = true;

  unlock() {
    _locked = false;
    if (_queue != null) {
      _value = _queue;
      _queue = null;
    }
  }

  T relock() {
    _locked = true;
    if (_queue != null) {
      _value = _queue;
      _queue = null;
    }
    return _value;
  }

  set value(T value) {
    if (_locked)
      _queue = value;
    else
      this._value = value;
  }

  T get value => _value;
}
