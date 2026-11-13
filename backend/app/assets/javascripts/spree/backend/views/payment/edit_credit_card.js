//= require jquery.payment
Spree.Views.Payment.EditCreditCard = Backbone.View.extend({
  initialize: function() {
    this.$(".cardNumber").payment('formatCardNumber');
    this.$(".cardExpiry").payment('formatCardExpiry');
    this.$(".cardCode").payment('formatCardCVC');

    this.render()
  },

  // `card` is the deprecated name of the `payment_source_id` field, still
  // supported for custom payment source forms.
  sourceSelector: '[name=payment_source_id], [name=card]',

  events: function() {
    var events = { 'change .cardNumber': 'render' };
    events['change ' + this.sourceSelector] = 'render';
    return events;
  },

  render: function() {
    var $sources = this.$(this.sourceSelector);
    var isNew = ($sources.filter(':checked').val() === 'new') || ($sources.length == 0);
    this.$('.js-new-credit-card-form').toggleClass('hidden', !isNew)
    this.$('.js-new-credit-card-form :input').prop('disabled', !isNew)

    this.$(".ccType").val($.payment.cardType(this.$('.cardNumber').val()))
  }
})
