var DragScrollable = Class.create();
DragScrollable.prototype = {
  initialize: function(element) {
    this.element = $(element);
    this.active = false;
    this.scrolling = false;

    // this.element.style.cursor = 'pointer';

    this.eventMouseDown = this.startScroll.bindAsEventListener(this);
    this.eventMouseUp   = this.endScroll.bindAsEventListener(this);
    this.eventMouseMove = this.scroll.bindAsEventListener(this);
    
    this.element.title = "Drag Image to Scroll"
    Event.observe(this.element, 'mousedown', this.eventMouseDown);
  },
  destroy: function() {
    Event.stopObserving(this.element, 'mousedown', this.eventMouseDown);
    Event.stopObserving(document, 'mouseup', this.eventMouseUp);
    Event.stopObserving(document, 'mousemove', this.eventMouseMove);
  },
  startScroll: function(event) {
    this.startX = Event.pointerX(event);
    this.startY = Event.pointerY(event);
    if (Event.isLeftClick(event) &&
        (this.startX < this.element.offsetLeft + this.element.clientWidth) &&
        (this.startY < this.element.offsetTop + this.element.clientHeight)) {
      this.element.style.cursor = 'move';
      Event.observe(document, 'mouseup', this.eventMouseUp);
      Event.observe(document, 'mousemove', this.eventMouseMove);
      this.active = true;
      Event.stop(event);
    }
  },
  endScroll: function(event) {
    // this.element.style.cursor = 'pointer';
    this.active = false;
    Event.stopObserving(document, 'mouseup', this.eventMouseUp);
    Event.stopObserving(document, 'mousemove', this.eventMouseMove);
    Event.stop(event);
  },
  scroll: function(event) {
    if (this.active) {
      this.element.scrollTop += (this.startY - Event.pointerY(event));
      this.element.scrollLeft += (this.startX - Event.pointerX(event));
      this.startX = Event.pointerX(event);
      this.startY = Event.pointerY(event);
    }
    Event.stop(event);
  }
}
