function scrollParentToChild(parent, child) {
    var parentRect = parent.getBoundingClientRect();
    var parentViewableArea = {
        height: parent.clientHeight,
        width: parent.clientWidth
    };

    var childRect = child.getBoundingClientRect();
    var isViewable = (childRect.top >= parentRect.top) && (childRect.bottom <= parentRect.top + parentViewableArea.height);
    if (!isViewable) {
        const scrollTop = childRect.top - parentRect.top;
        const scrollBot = childRect.bottom - parentRect.bottom;
        if (Math.abs(scrollTop) < Math.abs(scrollBot)) {
            parent.scrollTop += scrollTop;
        } else {
            parent.scrollTop += scrollBot;
        }
    }
}
class TouchpointsForms {
    touchpointsForms = {};
    touchpointsIndex = 0;
    userInitiated = true;
    //custom form logic
    formController = {
        "b28b92d9":{
            5:{
                "Yes":6,
                "No":8
            },
            6:{
                "Very relevant":8,
                "Somewhat relevant":8,
                "A little relevant":7,
                "Not at all relevant":7
            }
        },
        "0e8b71bf":{
            5:{
                "Yes":6,
                "No":8
            },
            6:{
                "Very relevant":8,
                "Somewhat relevant":8,
                "A little relevant":7,
                "Not at all relevant":7
            }
        }
    }
    constructor() { }
    initTouchpoints(e) {
        e.preventDefault();
        this.tpGetForms(this.touchpointsForms)
        $(".touchpoints-skipnav, #fba_directive").remove();
    }
    tpGetForms(obj) {
        var ep = '//touchpoints.app.cloud.gov/touchpoints/';
        let counter = 0;
        for (let index in obj) {
            let xhr = new XMLHttpRequest();
            let url = "/assets/touchpoints/"+ index + '.js';
            xhr.open("GET", url, false);
            xhr.onreadystatechange = () => {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    var sz = document.createElement('script');
                    sz.type = 'text/javascript';
                    sz.async = true;
                    let output = xhr.responseText;
                    output = output.replace(/^const touchpointForm.*$/gim, '')
                    output = output.replace(/this.loadCss\(\);$/gim, '')
                    output = output.replace(/d.body.appendChild\(this.dialogEl\);$/gim, 'd.querySelector("footer #touchpoints-container").appendChild(this.dialogEl);')
                    let fid = output.replace(/^.*formId.*?"(.+?)".*$/gims, "$1")
                    output = output.replace(/^(function FBAform)\(/gim, '$1' + fid + '\(')
                    output = output.replace(/d.querySelector\('.fba-modal'\)/gims, 'd.querySelector(\'[data-id="' + fid + '"]\').previousElementSibling')
                    sz.innerHTML = output;
                    var s = document.getElementsByTagName('script')[0];
                    s.parentNode.insertBefore(sz, s);
                    this.touchpointsForms[fid] = new window['FBAform' + fid](document, window)

                    if(Object.size(obj) - 1 == counter){
                        try {
                            this.overrideTouchpoints()
                        } catch (e) {}
                    }
                    counter++;
 
                }
            }
            xhr.send();
            let xhr2 = new XMLHttpRequest();
            xhr2.open("GET", ep + index + '.js');
            xhr2.send();
        }

    }
    tpCallback(){
        $(".touchpoints-form-wrapper small").remove();
        $(".usa-button:first").remove();
         $(".section-title-view").remove();
        if(Object.size(this.touchpointsForms)>1 && $("#fba-more-forms-yes").length == 0 ){
            $('.usa-alert--success div').append('<p class="more">Would you like to participate in another survey?<br /><button id="fba-more-forms-yes">Yes</button> <button id="fba-more-forms-no">No</button></p>')	
        }
		this.touchpointsIndex++
        if(Object.keys(this.touchpointsForms)[Object.size(this.touchpointsForms) - (1 + this.touchpointsIndex)] == $(".touchpoints-form-wrapper:visible").attr("data-touchpoints-form-id")){
			$('.usa-alert--success div .more').remove()
		}
	}
    overrideTouchpoints() {
        for (let fid in this.touchpointsForms) {
            this.extendFunction(this.touchpointsForms[fid], "formSuccess", this.tpCallback)
            // this.extendFunction(this.touchpointsForms[fid], "handleClick", (args,that)=>{
            //     let e=args[0];
            //     let currentForm = $(".fba-modal:not([hidden])").next().attr("data-id")
            //     if(that.formId == currentForm){
            //         if($(e.target).attr("id") == "fba-more-forms-yes"){
            //             this.showOtherForm();
            //         }else if($(e.target).attr("id") == "fba-more-forms-no"){
            //             this.closeCurrentForm(currentForm);
            //             this.touchpointsIndex = 0
            //         }
            //     }
            // })
            this.touchpointsForms[fid].handleClick = function () {
                new Function("e", `
                if (this.dialogOpen && e.target.closest('#fba-button') && !e.target.closest('.fba-modal-dialog')) {
                    this.closeDialog();
                }
            `).call(this,arguments[0])
            }
            this.touchpointsForms[fid].bindEventListeners = function () {
                new Function("d", `
                var self = this;
                d.addEventListener('keyup', function (event) {
                    var x = event.keyCode;
                    if( x == 27 && self.dialogOpen == true) {
                        self.closeDialog();
                    }
                });
                d.addEventListener('mousedown', function (event) {
                    self.handleClick(event);
                });
            `).call(this, document)
            }
            this.touchpointsForms[fid].loadButton = function () {
                new Function("d", `
                    this.buttonEl = document.createElement('a');
                    this.buttonEl.setAttribute('id', 'fba-button-${this.formId}');
                    this.buttonEl.setAttribute('data-id', '${this.formId}');
                    this.buttonEl.setAttribute('class', 'fixed-tab-button usa-button');
                    this.buttonEl.setAttribute('href', '#');
                    this.buttonEl.setAttribute('title', 'Help improve this site');
                    this.buttonEl.setAttribute('aria-haspopup', 'dialog');
                    this.buttonEl.addEventListener('click', this.handleButtonClick.bind(this), false);
                    this.buttonEl.innerHTML = this.options.modalButtonText;
                    d.querySelector("footer #touchpoints-container").appendChild(this.buttonEl);
                    this.loadFeebackSkipLink();
            `).call(this, document)
            }
            this.touchpointsForms[fid].closeDialog = function () {
                new Function("d", `
                    d.querySelector('[data-id="${this.formId}"]').previousElementSibling.setAttribute("hidden", true);
                    this.resetFormDisplay();
                    this.dialogOpen = false;
                    if(this.successState){
                        $("#touchpoints-container").remove();
                    }
            `).call(this, document)
            }
            this.extendFunction(this.touchpointsForms[fid], "closeDialog", (args,that)=>{
                this.touchpointsIndex = 0
            })
            this.touchpointsForms[fid].checkRequired = function(){
                return new Function("form",`
                    var requiredItems = form.querySelectorAll('[required]');
                    var questions = {};
                   
                    // Build a dictionary of questions which require an answer
                    Array.prototype.forEach.call(requiredItems, function(item) {
                        questions[item.name] = item
                    });
        
                    Array.prototype.forEach.call(requiredItems, function(item) {
                        switch (item.type) {
                        case 'radio':
                            if (item.checked)
                                delete (questions[item.name]);
                            break;
                        case 'checkbox':
                            if (item.checked)
                                delete (questions[item.name]);
                            break;
                        case 'select-one':
                            if (item.selectedIndex > 0)
                                delete (questions[item.name]);
                            break;
                        default:
                            if (item.value && item.value.length > 0)
                                delete (questions[item.name]);
                        }
                    });
                    for (var key in questions) {
                        this.showValidationError(questions[key], 'You must respond to question ');
                        return false;
                    }
                    return true;
            `).call(this,arguments[0])
            }
            this.touchpointsForms[fid].pagination = function () {
                new Function("d", `
                var previousButtons = document.getElementsByClassName("previous-section");
                var nextButtons = document.getElementsByClassName("next-section");
                var self = this;
                for (var i = 0; i < previousButtons.length; i++) {
                    previousButtons[i].addEventListener('click', function(e) {
                        e.preventDefault();
                        var currentPage = e.target.closest(".section");
                        //if (!this.validateForm(currentPage))
                        //    return false;
                        currentPage.classList.remove("visible");
                        currentPage.previousElementSibling.classList.add("visible");
    
                        // if in a modal, scroll to the top of the modal on previous button click
                        if (document.getElementsByClassName("fba-modal")[0]) {
                            document.getElementsByClassName("fba-modal")[0].scrollTo(0, 0);
                        } else {
                            window.scrollTo(0, 0);
                        }
                    }
                    .bind(self));
                }
                for (var i = 0; i < nextButtons.length; i++) {
                    nextButtons[i].addEventListener('click', function(e) {
                        e.preventDefault();
                        var currentPage = e.target.closest(".section");
                        if (!this.validateForm(currentPage))
                           return false;
                        currentPage.classList.remove("visible");
                        currentPage.nextElementSibling.classList.add("visible");
                        window.scrollTo(0, 0);
    
                        // if in a modal, scroll to the top of the modal on next button click
                        if (document.getElementsByClassName("fba-modal")[0]) {
                            document.getElementsByClassName("fba-modal")[0].scrollTo(0, 0);
                        } else {
                            window.scrollTo(0, 0);
                        }
                    }
                    .bind(self))
                }
            `).call(this, document)
            }
            this.touchpointsForms[fid].showValidationError = function(){
                new Function("question", "error",`
                    var questionDiv = question.closest(".question");
                    var label = questionDiv.querySelector(".usa-label") || questionDiv.querySelector(".usa-legend");
                    var questionNum = $(label).attr("data-question-number").replace(/^(.+?\\.).*$/gi,"$1");
                    if($(questionDiv).find('input[id$="_other"][required]').length > 0){
                        questionNum += " Please enter other text."
                    }
                    // show page with validation error
                    var errorPage = question.closest(".section");
                    if (!errorPage.classList.contains("visible")) {
                        var visiblePage = document.getElementsByClassName("section visible")[0];
                        visiblePage.classList.remove("visible");
                        errorPage.classList.add("visible");
                    }
        
                    questionDiv.setAttribute('class', 'usa-form-group usa-form-group--error');
                    var span = document.createElement('span');
                    span.setAttribute('id', 'input-error-message');
                    span.setAttribute('role', 'alert');
                    span.setAttribute('class', 'usa-error-message');
                    span.innerText = error + questionNum;
                    label.parentNode.insertBefore(span, label.nextSibling);
                    var input = document.createElement('input');
                    input.setAttribute('hidden', 'true');
                    input.setAttribute('id', 'input-error');
                    input.setAttribute('type', 'text');
                    input.setAttribute('name', 'input-error');
                    input.setAttribute('aria-describedby', 'input-error-message');
                    questionDiv.appendChild(input);
                    questionDiv.scrollIntoView();
                    questionDiv.focus();
        
                    // enable submit button ( so user can fix error and resubmit )
                    var submitButton = document.querySelector("[type='submit']");
                    submitButton.disabled = false;
                    submitButton.classList.remove("aria-disabled");
            `).call(this,arguments[0],arguments[1])
            }
            this.touchpointsForms[fid].handleButtonClick = function () {
                new Function("e", `
                    e.preventDefault();
                    this.activatedButton = e.target;
                    this.loadDialog();
            `).call(this, arguments[0])
            }
            formOptions['modalButtonText'] = '<span>Help improve this site</span>';
            this.touchpointsForms[fid].successText = function(){return '<p>Thank you for taking our survey and for helping us serve you better.</p><p>If you have a question or would like to be contacted, please submit a <a href="/forms/opb.htm?'+window.location.pathname+'">Request for Information</a>.</p>';}
            this.touchpointsForms[fid].init(formOptions);
        }
        for (let ind in this.touchpointsForms) {
            this.setupTouchpoints($('[data-id="' + ind + '"]').prev('.fba-modal'))
            let index = ind
            if(Object.size(this.touchpointsForms) > 1 && Object.keys(this.touchpointsForms)[Object.size(this.touchpointsForms)-1] != ind){
                index = Object.keys(this.touchpointsForms)[Object.size(this.touchpointsForms) - 1];
            }
            this.touchpointsForms[index].loadDialog()
            $('[data-id="' + index + '"]').click();
        }
    }
    extendFunction(obj, originalFunc, newFunc) {
        let oldFunc = obj[originalFunc];
        let self = this;
        obj[originalFunc] = function(){
            oldFunc.apply(this, arguments);
            newFunc.call(self, arguments, this);
        }
    }
    setupTouchpoints(el) {
        $("#fba-button").remove();
        $(window).scroll();
        var self = this;
        el.each(function () {
            var that = $(this)
            var $formBody = $(this).find('.touchpoints-form-body')
            $formBody.parent().addClass('loaded')
            var $sliderInner = $formBody.children().not('input, .sliderInner').wrapAll('<div class="sliderInner">').parent()
            var slideCount = $sliderInner.find('.section').length
            var slideWidth = $sliderInner.find('.section').first().width() || 500
            var sliderInnerWidth = slideCount * slideWidth;
            $('.sliderInner').append('<div class="section hidden" style="height:100px"></div>')
            that.find('.usa-banner__inner [aria-hidden="true"]').removeAttr("aria-hidden")
            that.find(".other-option").attr("disabled","disabled")
            that.find(".other-option").attr("maxlength",75)
            that.find(".usa-textarea").attr("maxlength",1000).css("resize","none")
            $('input[type="radio"][value="OTHER"]').each(function(){
                let otherRadio = $(this)
                $(this).parents(".question-options").find('input[type="radio"]').not('input[value="OTHER"]').each(function(){
                    $(this).change(function(){
                        otherRadio.change()
                    })
                })
            })
            that.find('input[value="OTHER"]').change(function(){
                if(!$(this).prop("checked")){
                    $(this).siblings("input").attr("disabled","disabled")
                    $(this).siblings("input").val("")
                    $(this).siblings("input").removeAttr("required")
                    $(this).siblings("input").keyup()
                }else{
                    $(this).siblings("input").removeAttr("disabled")
                }
            })
            that.find(".other-option,.usa-textarea").each(function(){
                $(this).focus(function(){
                    if(!$(this).next(".cr-container").length){
                        $(this).after('<div class="cr-container"><span class="characters-remaining">'+$(this).attr("maxlength")+'</span> characters remaining</div>')
                    }
                })
                $(this).keyup(function(){
                    let count = $(this).attr("maxlength") - ($(this).val().length)
                    $(this).next(".cr-container").find(".characters-remaining").html(count)
                    if(count == 0){
                        $(this).next(".cr-container").addClass("full")
                    }else{
                        $(this).next(".cr-container").removeClass("full")
                    }
                })
            })
            that.find(".section legend").each(function(){
                $(this).html($(this).html()+ '<span class="asterisk">*</span>')
                $(this).parents(".section").append('<p class="asterisk-explanation">Required questions are marked with an asterisk ( <span class="asterisk">*</span> ).</p>')
            })
            if ($(this).find("#answer_20").length && $(this).find("#answer_20").val() == "") {
                $(this).find("#answer_20").val(self.userInitiated)
            }
            $(this).next(".usa-button").click(function () {
                that.find(".fba-modal-dialog .sliderInner .section.visible").removeClass("visible")
                that.find(".fba-modal-dialog .sliderInner .section").eq(0).addClass("visible")
                that.find(".fba-modal-dialog .sliderInner .section").eq(0)[0].scrollIntoView()
                $sliderInner.parent().css('height', that.find(".fba-modal-dialog .sliderInner .section").eq(0).height() + 'px')
            })
            $formBody.css({
                width: slideWidth,
                height: $sliderInner.find('.section').eq(0).height() + 30 + 'px'
            });
            $(this).find(".pagination-buttons a, .star_rating input, .star_rating path").attr("tabindex", "-1")
            function move(coef, focusSkip) {
                if($(window).width()>768){
                    focusSkip = focusSkip? true: false;
                    var widthcoef = (coef * -1 * slideWidth)
                    $sliderInner.animate({
                        left: (widthcoef < 0 ? "" : "+") + widthcoef
                    }, 0, function () {
                        if(!$('label[for="input-error"]').size()){
                            $("#input-error").after('<label for="input-error" class="invisible">error</input>')
                        }
                        if(focusSkip){
                            var visibleSecIndex = $(this).find(".section").index($(this).find(".section.visible"))
                            var newSlide = that.find(".sliderInner").find(".section").eq(visibleSecIndex) 
                        }else{
                            var newSlide = $(this).find(".section.visible")
                            if(coef < 0){
                                var currentSlide = $(this).find(".section.visible").next()
                                newSlide = currentSlide.prevAll(".section").not(".disabled").first()
                            }else if(coef > 0){
                                var currentSlide = $(this).find(".section.visible").prev()
                                newSlide = currentSlide.nextAll(".section").not(".disabled").first()
                            }
                        }
                        if(!newSlide[0]){
                            newSlide = $(this).find(".section").eq(0)
                        }
                        $(this).css("left", "").parent().css('height', newSlide.height() + 100 + 'px')
                        scrollParentToChild($(this)[0], $(this).find(".section.visible .section-header")[0]) 
                        $(".section.visible").removeClass("visible")
                        newSlide.addClass("visible")
                        newSlide.find("input").first().focus()
                        newSlide[0].scrollIntoView()
                        
                         if(!$(newSlide[0]).attr("data-original-height")){
                            let bugHeight = newSlide.height() == 0 ? 189.625 : newSlide.height()
                            $(newSlide[0]).css('height',bugHeight + 100 + "px").attr("data-original-height",bugHeight+ 100)
                        }else{
                            let originalHeight = $(newSlide[0]).attr("data-original-height")
                            $(this).parent().css('height', originalHeight + "px")
                            $(newSlide[0]).css('height', originalHeight + "px")
                        }
                    });
                }
                
            }
            $(this).find(".fba-modal-close").click(function() {
                self.touchpointsForms[$(this).parents('.touchpoints-form-wrapper').attr('data-touchpoints-form-id')].closeDialog()
            })

            $(this).find('a.previous-section').click(function() {
                move(-1);
            });

            $(this).find('a.next-section').click(function(e) {
                move(1);
            });

            $(this).find('.submit_form_button').click(function(e) {
                move(0);
            });
            $(this).find('.usa-label,.usa-legend').each(function(){
                let number = $(this).text().replace(/^.*?([\d]+?\.).*$/mi,"$1")
                let text = $(this).html().replace(/^.*?[\d]+?\.(.*)$/mi,"$1")
                $(this).html(text)
                $(this).attr("data-question-number",number.replace("*","").trim());
            })

            $(window).resize(function(){
                move(0);
            })
            el.find('form input:not([type="text"]):not([type="hidden"])').attr("required","required")
            el.find("form").on("change",function(e){
                let formId = $(this).attr("action").replace(/^.*\/(.*?)\/submissions.json$/gi,"$1")
                let thisSlide = $(this).find(".section.visible")
                let currentQuestion =  $(this).find(".section").index(thisSlide) + 1
                $(this).find(".section").each(function(i){
                    if(i >= (currentQuestion - 1)){
                        $(this).removeClass("disabled")
                        $(this).find("input:not([disabled])").attr("required","required")
                        $(this).find('[tabindex]').not(".pagination-buttons a, .star_rating input, .star_rating path").removeAttr("tabindex")
                    }
                })
                if(self.formController[formId][currentQuestion]){
                    let disabled = (self.formController[formId][currentQuestion][$(e.target).val()] - currentQuestion - 1)
                    for(let i = 1; i <= disabled;i++){
                        $(this).find(".section").eq(currentQuestion - 1 + i).addClass("disabled")
                        $(this).find(".section").eq(currentQuestion - 1 + i).find("input").removeAttr("required")
                        $(this).find(".section").eq(currentQuestion - 1 + i).find("*").not(".pagination-buttons a, .star_rating input, .star_rating path").attr("tabindex","-1")
                    }
                }
            })
            $(this).find('.fba-modal-dialog .star_rating svg').each(function () {
                $(this).click(function () {
                    starRating.call(this);
                })
                $(this).keyup(function (event) {
                    if (event.keyCode === 13 || event.keyCode === 32) {
                        starRating.call(this);
                    }
                });
            })
            function starRating() {
                var these = $(this);
                $(this).parents(".star_rating").find("input").removeAttr("checked")
                $("#" + $(this).parent().attr("for")).prop("checked", true)
                $(this).parents(".star_rating").find("svg").each(function (i) {
                    if (i > $('.star_rating svg').index(these)) {
                        $(this).removeAttr("fill")
                    } else {
                        $(this).attr("fill", "#fdd663")
                    }
                })
            }
            $(this).find(".fba-modal-dialog .sliderInner textarea,.fba-modal-dialog .sliderInner input,.fba-modal-dialog .sliderInner select,.fba-modal-dialog .sliderInner svg,.fba-modal-dialog .sliderInner button").focus(function(e) {
                let parent = $(this).parents(".sliderInner")
                let visibleSecIndex = parent.find(".section").index(parent.find(".section.visible"))
                let focusedSecIndex = parent.find(".section").index($(this).parents(".section"))

                if (focusedSecIndex != visibleSecIndex){
                    that.find(".fba-modal-dialog .sliderInner .section.visible").removeClass("visible")
                    that.find(".fba-modal-dialog .sliderInner .section").eq(focusedSecIndex).addClass("visible")
                    move(focusedSecIndex - visibleSecIndex, true)
                }
            })
        })
    }
    showOtherForm() {
        let currForm = Object.keys(this.touchpointsForms)[Object.size(this.touchpointsForms) - 1];
        let newForm = Object.keys(this.touchpointsForms)[Object.size(this.touchpointsForms) - (1 + this.touchpointsIndex)];
        this.touchpointsForms[currForm].closeDialog()
        this.touchpointsForms[newForm].loadDialog()
        $('a[data-id="' + newForm + '"]').click()
    }
    closeCurrentForm(currentForm) {
        this.touchpointsForms[currentForm].closeDialog()
    }
}

(function () {
    let sd = window.location.host.split('.')[0]
    const psd = /^(beta|data|bls|www|stats)$/
    let samplingRate = 1
    let touchpointsUrls = {
        "/": "b28b92d9" //should always be last
    }
    if(!sd.match(psd)){//staging
        samplingRate = 0
        touchpointsUrls = {
            "/": "0e8b71bf" //should always be last
        }
    }
    $('body footer').append('<div id="touchpoints-container"><a class="fixed-tab-button usa-button" id="fba-button" href="#" title="Help improve this site"><span>Help improve this site</span></a></div>');
    $(window).scroll(function(){
       if($(this).scrollTop()<100){
          $("#touchpoints-container .fixed-tab-button").removeClass("collapsed")
       }else if(!$("#touchpoints-container .fixed-tab-button").hasClass("collapsed")){
          $("#touchpoints-container .fixed-tab-button").addClass("collapsed")
       }
    });
    var touchpoints = new TouchpointsForms();
    for(url in touchpointsUrls) {
       let re = new RegExp("^" + url.replace(/\/$/gi,"") + "(\/|$)");
       if(String(window.location.pathname).match(re)){
          touchpoints.touchpointsForms[touchpointsUrls[url]] = {};
          break;
       }
    }
    var rand = Math.floor(Math.random() * 100) + 1;
    if(!Boolean(bls_getCookie("touchpoints")) && rand <= samplingRate) {
       bls_setCookie("touchpoints", true, 90)
       touchpoints.userInitiated = false;
       setTimeout(function () {
          $(".fixed-tab-button").click();
       }, 1000);
    }
    $(".usa-button").click(function (e) {
       touchpoints.initTouchpoints(e);
       $(this).unbind('click');
       $(".usa-form").hide();
       let intro = '';
       if(!touchpoints.userInitiated){
        intro = "Thank you for visiting BLS.gov. You have been randomly chosen to answer a few questions to let us know what we're doing well and where we can improve BLS.gov. The feedback you provide will help us improve your website experience.";
       }else{
        intro = "Thank you for visiting BLS.gov. Please answer a few questions to let us know what we're doing well and where we can improve BLS.gov. The feedback you provide will help us improve your website experience.";
       }

       pra = `This voluntary survey is being collected by the Bureau of Labor Statistics under 
       OMB No. 1225-0088 (Expiration Date: 1/31/2027). We estimate that this survey takes 
       3 minutes to complete. If you have any comments regarding this estimate, send them to 
       <a href="mailto:BLS_PRA_Public@bls.gov">BLS_PRA_Public@bls.gov</a>. You are not required to respond to this collection unless it 
       displays a currently valid OMB control number. Your participation is voluntary, and 
       you have the right to stop at any time.<br /> <br /> 
       This survey is being administered by Touchpoints and resides on a server outside of 
       the BLS Domain. The BLS cannot guarantee the protection of survey responses and advises 
       against the inclusion of sensitive personal information in any response.`;
       
       $(".usa-form").after('<div id="fba-intro"><img src="/images/bls_emblem_lrg.gif" alt="bls logo" /><p>'+intro+'</p><p class="pra">'+pra+'</p><p><a class="usa-button continue-section" href="#">Continue</a></p></div>');

       $(".continue-section").click(function(){
        $("#fba-intro").prev().show();
        $("#fba-intro").remove();
        $(window).resize();
       });
    })

})();