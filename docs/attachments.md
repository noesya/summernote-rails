# Attachments

To handle attachments, we use two native features from Rails: Active Storage & Action Text.

## Import assets

In app/assets/javascripts/application.js, add Active Storage and Summernote Rails JS files:

```javascript
//= require activestorage
//= ...
//= require summernote/summernote-lite.min
//= require summernote-rails
```

## Usage

In your model, you must declare that your attribute use Summernote.

```ruby
class Article < ApplicationRecord
  # ...
  has_summernote :text
  # ...
end
```

In the form view, if you use Rails native form builder, you must provide `data-direct-upload-url` and `data-blob-url-template` attributes:

```erb
<%= form_for @article do |f| %>
  <div class="field">
    <%= f.label :text %>
    <%= f.text_area :text, data: {
          provider: 'summernote',
          direct_upload_url: rails_direct_uploads_url,
          blob_url_template: rails_service_blob_url(":signed_id", ":filename")
        } %>
  </div>
<% end %>  
```

If you use Simple Form, these attributes are automatically added, so you don't have to worry.

Then, you have to edit Summernote's initialization options:

```javascript
$(function () {
    'use strict';
    $('[data-provider="summernote"]').each(function () {
        $(this).summernote({
            height: 300,
            callbacks: {
                onImageUpload: function (files) {
                    var attachmentUpload = new SummernoteAttachmentUpload(this, files[0]);
                    attachmentUpload.start();
                },
                onMediaDelete: function (_, $editable) {
                    $.summernote.rails.cleanEmptyAttachments($editable);
                },
                onKeyup: function (e) {
                    var $editable = $(e.currentTarget);
                    if (e.keyCode === 8) {
                        $.summernote.rails.cleanEmptyAttachments($editable);
                    }
                }
            }
        });
    });
});
```

## What happens under the hood?

### Back-end

When we declare `has_summernote :text` in the model:
- We make the attribute serializable as an `ActionText::Content` object.
- We create an association `text_summernote_embeds` with `has_many_attached`, to keep track of the ActiveStorage blobs inside.
- We define a `before_save` callback which handles the association above.

### Front-end

When we upload a file, we use Active Storage Direct Upload to create the blob and upload to the service configured for the application.

Then, we create an `<action-text-attachment>` and a preview inside of it. The `sgid` attribute in the `<action-text-attachment>` allows us to keep track of the blobs.

The definition of the `onMediaDelete` and `onKeyup` callbacks makes sure that if the attachment tag is empty, we delete the blob correctly.

The preview inside `<action-text-attachment>` is removed before it is inserted in the database.
