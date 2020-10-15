/*!
 * Ext JS Library 3.4.0
 * Copyright(c) 2006-2011 Sencha Inc.
 * licensing@sencha.com
 * http://www.sencha.com/license
 */
Ext.ns('Ext.ux.form');
Ext.ux.form.ComboBoxWithClear = Ext.extend(Ext.form.ComboBox,{
    initComponent : function(){
    	Ext.ux.form.ComboBoxWithClear.superclass.initComponent.call(this);
        this.triggerConfig = {
            tag:'span', cls:'x-form-twin-triggers', cn:[
            {tag: "img", src: Ext.BLANK_IMAGE_URL, alt: "", cls: "x-form-trigger " + this.triggerClass },
            {tag: "img", src: Ext.BLANK_IMAGE_URL, alt: "", cls: "x-form-trigger x-form-clear-trigger" }
        ]};
    },

    getTrigger : function(index){
        return this.triggers[index];
    },
    
    afterRender: function(){
    	Ext.ux.form.ComboBoxWithClear.superclass.afterRender.call(this);
        var triggers = this.triggers,
            i = 0,
            len = triggers.length;
            
        for(; i < len; ++i){
            if(this['hideTrigger' + (i + 1)]){
                    triggers[i].hide();
                }
        }    
    },
    initTrigger : function(){
        var ts = this.trigger.select('.x-form-trigger', true),
            triggerField = this;
        ts.each(function(t, all, index){
            var triggerIndex = 'Trigger'+(index+1);
            t.hide = function(){
                var w = triggerField.wrap.getWidth();
                this.dom.style.display = 'none';
                triggerField.el.setWidth(w-triggerField.trigger.getWidth());
                triggerField['hidden' + triggerIndex] = true;
            };
            t.show = function(){
                var w = triggerField.wrap.getWidth();
                this.dom.style.display = '';
                triggerField.el.setWidth(w-triggerField.trigger.getWidth());
                triggerField['hidden' + triggerIndex] = false;
            };
            this.mon(t, 'click', this['onTrigger'+(index==0?"":(index+1))+'Click'], this, {preventDefault:true});
            t.addClassOnOver('x-form-trigger-over');
            t.addClassOnClick('x-form-trigger-click');
        }, this);
        this.triggers = ts.elements;
    },
    getTriggerWidth: function(){
        var tw = 0;
        Ext.each(this.triggers, function(t, index){
            var triggerIndex = 'Trigger' + (index + 1),
                w = t.getWidth();
            if(w === 0 && !this['hidden' + triggerIndex]){
                tw += this.defaultTriggerWidth;
            }else{
                tw += w;
            }
        }, this);
        return tw;
    },
    onDestroy : function() {
        Ext.destroy(this.triggers);
        Ext.ux.form.ComboBoxWithClear.superclass.onDestroy.call(this);
    },
    clearValue: Ext.emptyFn,
    onTrigger2Click : function(){
    	this.clearValue();
    }
});
Ext.reg('comboClear', Ext.ux.form.ComboBoxWithClear);

Ext.ux.form.TriggerWithClear = Ext.extend(Ext.form.TriggerField, {
    initComponent : function(){
    	Ext.ux.form.TriggerWithClear.superclass.initComponent.call(this);
        this.triggerConfig = {
            tag:'span', cls:'x-form-twin-triggers', cn:[
            {tag: "img", src: Ext.BLANK_IMAGE_URL, alt: "", cls: "x-form-trigger " + this.triggerClass },
            {tag: "img", src: Ext.BLANK_IMAGE_URL, alt: "", cls: "x-form-trigger x-form-clear-trigger" }
        ]};
    },

    getTrigger : function(index){
        return this.triggers[index];
    },
    
    afterRender: function(){
    	Ext.ux.form.TriggerWithClear.superclass.afterRender.call(this);
        var triggers = this.triggers,
            i = 0,
            len = triggers.length;
            
        for(; i < len; ++i){
            if(this['hideTrigger' + (i + 1)]){
                    triggers[i].hide();
                }
        }    
    },
    initTrigger : function(){
        var ts = this.trigger.select('.x-form-trigger', true),
            triggerField = this;
        ts.each(function(t, all, index){
            var triggerIndex = 'Trigger'+(index+1);
            t.hide = function(){
                var w = triggerField.wrap.getWidth();
                this.dom.style.display = 'none';
                triggerField.el.setWidth(w-triggerField.trigger.getWidth());
                triggerField['hidden' + triggerIndex] = true;
            };
            t.show = function(){
                var w = triggerField.wrap.getWidth();
                this.dom.style.display = '';
                triggerField.el.setWidth(w-triggerField.trigger.getWidth());
                triggerField['hidden' + triggerIndex] = false;
            };
            this.mon(t, 'click', this['onTrigger'+(index==0?"":(index+1))+'Click'], this, {preventDefault:true});
            t.addClassOnOver('x-form-trigger-over');
            t.addClassOnClick('x-form-trigger-click');
        }, this);
        this.triggers = ts.elements;
    },
    getTriggerWidth: function(){
        var tw = 0;
        Ext.each(this.triggers, function(t, index){
            var triggerIndex = 'Trigger' + (index + 1),
                w = t.getWidth();
            if(w === 0 && !this['hidden' + triggerIndex]){
                tw += this.defaultTriggerWidth;
            }else{
                tw += w;
            }
        }, this);
        return tw;
    },
    onDestroy : function() {
        Ext.destroy(this.triggers);
        Ext.ux.form.TriggerWithClear.superclass.onDestroy.call(this);
    },
    clearValue: Ext.emptyFn,
    onTrigger2Click : function(){
    	this.clearValue();
    }
});
Ext.reg('triggerClear', Ext.ux.form.TriggerWithClear);

Ext.ux.form.DateFieldWithClear = Ext.extend(Ext.form.DateField,{
    initComponent : function(){
    	Ext.ux.form.DateFieldWithClear.superclass.initComponent.call(this);
        this.triggerConfig = {
            tag:'span', cls:'x-form-twin-triggers', cn:[
            {tag: "img", src: Ext.BLANK_IMAGE_URL, alt: "", cls: "x-form-trigger " + this.triggerClass },
            {tag: "img", src: Ext.BLANK_IMAGE_URL, alt: "", cls: "x-form-trigger x-form-clear-trigger" }
        ]};
    },

    getTrigger : function(index){
        return this.triggers[index];
    },
    
    afterRender: function(){
    	Ext.ux.form.ComboBoxWithClear.superclass.afterRender.call(this);
        var triggers = this.triggers,
            i = 0,
            len = triggers.length;
            
        for(; i < len; ++i){
            if(this['hideTrigger' + (i + 1)]){
                    triggers[i].hide();
                }
        }    
    },
    initTrigger : function(){
        var ts = this.trigger.select('.x-form-trigger', true),
            triggerField = this;
        ts.each(function(t, all, index){
            var triggerIndex = 'Trigger'+(index+1);
            t.hide = function(){
                var w = triggerField.wrap.getWidth();
                this.dom.style.display = 'none';
                triggerField.el.setWidth(w-triggerField.trigger.getWidth());
                triggerField['hidden' + triggerIndex] = true;
            };
            t.show = function(){
                var w = triggerField.wrap.getWidth();
                this.dom.style.display = '';
                triggerField.el.setWidth(w-triggerField.trigger.getWidth());
                triggerField['hidden' + triggerIndex] = false;
            };
            this.mon(t, 'click', this['onTrigger'+(index==0?"":(index+1))+'Click'], this, {preventDefault:true});
            t.addClassOnOver('x-form-trigger-over');
            t.addClassOnClick('x-form-trigger-click');
        }, this);
        this.triggers = ts.elements;
    },
    getTriggerWidth: function(){
        var tw = 0;
        Ext.each(this.triggers, function(t, index){
            var triggerIndex = 'Trigger' + (index + 1),
                w = t.getWidth();
            if(w === 0 && !this['hidden' + triggerIndex]){
                tw += this.defaultTriggerWidth;
            }else{
                tw += w;
            }
        }, this);
        return tw;
    },
    onDestroy : function() {
        Ext.destroy(this.triggers);
        Ext.ux.form.DateFieldWithClear.superclass.onDestroy.call(this);
    },
    onTrigger2Click : function(){
    	this.value="";
    	this.el.dom.value = '';
    }
});
Ext.reg('datefieldClear', Ext.ux.form.DateFieldWithClear);

Ext.ux.form.TextWithClear = Ext.extend(Ext.form.TriggerField, {
    initComponent : function(){
    	Ext.ux.form.TextWithClear.superclass.initComponent.call(this);
    },
    triggerClass: 'x-form-clear-trigger',
    onDestroy : function() {
        Ext.destroy(this.triggers);
        Ext.ux.form.TextWithClear.superclass.onDestroy.call(this);
    },
    clearValue: Ext.emptyFn,
    onTriggerClick : function(){
    	this.clearValue();
    }
});
Ext.reg('textfieldClear', Ext.ux.form.TextWithClear);
