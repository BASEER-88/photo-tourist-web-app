(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .factory("spa-demo.subjects.TagsAuthz", TagsAuthzFactory);

  TagsAuthzFactory.$inject = ["spa-demo.authz.Authz",
                                "spa-demo.authz.BasePolicy"];
  function TagsAuthzFactory(Authz, BasePolicy) {
    function TagsAuthz() {
      BasePolicy.call(this, "Tag");
    }

      //start with base class prototype definitions
    TagsAuthz.prototype = Object.create(BasePolicy.prototype);
    TagsAuthz.constructor = TagsAuthz;

      //override and add additional methods
    TagsAuthz.prototype.canQuery = function() {
      //console.log("BasePolicy.canQuery");
      return Authz.isAuthenticated();
    };
    TagsAuthz.prototype.canCreate=function() {
      //console.log("ItemsAuthz.canCreate");
      return Authz.isAuthenticated();
    };
    // TagsAuthz.prototype.canUpdate=function(tag) {
    //   //console.log("ItemsAuthz.canCreate");
    //   return Authz.isOrganizer(tag);
    // };

    return new TagsAuthz();
  }
})();
