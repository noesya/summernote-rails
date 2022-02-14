//= require ./summernote-rails/attachment_upload
//= require_self
$(function () {
    'use strict';

    // Handle attachments removal by verifying absence of image, video or text.
    $.extend($.summernote, {
        rails: {
            cleanEmptyAttachments: function ($field) {
                $('action-text-attachment', $field).each(function (_, attachment) {
                    var hasImage = $('img', attachment).length > 0,
                        hasVideo = $('video', attachment).length > 0,
                        hasText = attachment.innerText.trim() !== '';

                    if (!hasImage && !hasVideo && !hasText) {
                        $(attachment).remove();
                        $field.trigger('input');
                    }
                });
            }
        }
    });

    $.summernote.dom.isAttachment = function (node) {
        return node && (/^ACTION-TEXT-ATTACHMENT/).test(node.nodeName.toUpperCase());
    };

    // Override to handle <action-text-attachment> as block nodes.
    // By default, they're considered as inline, thus Summernote's magic process moved attachments' previews outside of their block.
    // Source: https://github.com/summernote/summernote/blob/4d7f3c48c41388a8f9ace336018891019d0eaf62/src/js/core/dom.js#L105
    $.summernote.dom.isInline = function (node) {
        return !this.isBodyContainer(node) &&
         !this.isList(node) &&
         !this.makePredByNodeName('HR')(node) &&
         !this.isPara(node) &&
         !this.makePredByNodeName('TABLE')(node) &&
         !this.makePredByNodeName('BLOCKQUOTE')(node) &&
         !this.makePredByNodeName('DATA')(node) &&
         !this.isAttachment(node);
    };
});
