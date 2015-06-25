(function() {
  var NodeTypes, ParameterMissing, Utils, createGlobalJsRoutesObject, defaults, root,
    __hasProp = {}.hasOwnProperty;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  ParameterMissing = function(message) {
    this.message = message;
  };

  ParameterMissing.prototype = new Error();

  defaults = {
    prefix: "",
    default_url_options: {}
  };

  NodeTypes = {"GROUP":1,"CAT":2,"SYMBOL":3,"OR":4,"STAR":5,"LITERAL":6,"SLASH":7,"DOT":8};

  Utils = {
    serialize: function(object, prefix) {
      var element, i, key, prop, result, s, _i, _len;

      if (prefix == null) {
        prefix = null;
      }
      if (!object) {
        return "";
      }
      if (!prefix && !(this.get_object_type(object) === "object")) {
        throw new Error("Url parameters should be a javascript hash");
      }
      if (root.jQuery) {
        result = root.jQuery.param(object);
        return (!result ? "" : result);
      }
      s = [];
      switch (this.get_object_type(object)) {
        case "array":
          for (i = _i = 0, _len = object.length; _i < _len; i = ++_i) {
            element = object[i];
            s.push(this.serialize(element, prefix + "[]"));
          }
          break;
        case "object":
          for (key in object) {
            if (!__hasProp.call(object, key)) continue;
            prop = object[key];
            if (!(prop != null)) {
              continue;
            }
            if (prefix != null) {
              key = "" + prefix + "[" + key + "]";
            }
            s.push(this.serialize(prop, key));
          }
          break;
        default:
          if (object) {
            s.push("" + (encodeURIComponent(prefix.toString())) + "=" + (encodeURIComponent(object.toString())));
          }
      }
      if (!s.length) {
        return "";
      }
      return s.join("&");
    },
    clean_path: function(path) {
      var last_index;

      path = path.split("://");
      last_index = path.length - 1;
      path[last_index] = path[last_index].replace(/\/+/g, "/");
      return path.join("://");
    },
    set_default_url_options: function(optional_parts, options) {
      var i, part, _i, _len, _results;

      _results = [];
      for (i = _i = 0, _len = optional_parts.length; _i < _len; i = ++_i) {
        part = optional_parts[i];
        if (!options.hasOwnProperty(part) && defaults.default_url_options.hasOwnProperty(part)) {
          _results.push(options[part] = defaults.default_url_options[part]);
        }
      }
      return _results;
    },
    extract_anchor: function(options) {
      var anchor;

      anchor = "";
      if (options.hasOwnProperty("anchor")) {
        anchor = "#" + options.anchor;
        delete options.anchor;
      }
      return anchor;
    },
    extract_trailing_slash: function(options) {
      var trailing_slash;

      trailing_slash = false;
      if (defaults.default_url_options.hasOwnProperty("trailing_slash")) {
        trailing_slash = defaults.default_url_options.trailing_slash;
      }
      if (options.hasOwnProperty("trailing_slash")) {
        trailing_slash = options.trailing_slash;
        delete options.trailing_slash;
      }
      return trailing_slash;
    },
    extract_options: function(number_of_params, args) {
      var last_el;

      last_el = args[args.length - 1];
      if (args.length > number_of_params || ((last_el != null) && "object" === this.get_object_type(last_el) && !this.look_like_serialized_model(last_el))) {
        return args.pop();
      } else {
        return {};
      }
    },
    look_like_serialized_model: function(object) {
      return "id" in object || "to_param" in object;
    },
    path_identifier: function(object) {
      var property;

      if (object === 0) {
        return "0";
      }
      if (!object) {
        return "";
      }
      property = object;
      if (this.get_object_type(object) === "object") {
        if ("to_param" in object) {
          property = object.to_param;
        } else if ("id" in object) {
          property = object.id;
        } else {
          property = object;
        }
        if (this.get_object_type(property) === "function") {
          property = property.call(object);
        }
      }
      return property.toString();
    },
    clone: function(obj) {
      var attr, copy, key;

      if ((obj == null) || "object" !== this.get_object_type(obj)) {
        return obj;
      }
      copy = obj.constructor();
      for (key in obj) {
        if (!__hasProp.call(obj, key)) continue;
        attr = obj[key];
        copy[key] = attr;
      }
      return copy;
    },
    prepare_parameters: function(required_parameters, actual_parameters, options) {
      var i, result, val, _i, _len;

      result = this.clone(options) || {};
      for (i = _i = 0, _len = required_parameters.length; _i < _len; i = ++_i) {
        val = required_parameters[i];
        if (i < actual_parameters.length) {
          result[val] = actual_parameters[i];
        }
      }
      return result;
    },
    build_path: function(required_parameters, optional_parts, route, args) {
      var anchor, opts, parameters, result, trailing_slash, url, url_params;

      args = Array.prototype.slice.call(args);
      opts = this.extract_options(required_parameters.length, args);
      if (args.length > required_parameters.length) {
        throw new Error("Too many parameters provided for path");
      }
      parameters = this.prepare_parameters(required_parameters, args, opts);
      this.set_default_url_options(optional_parts, parameters);
      anchor = this.extract_anchor(parameters);
      trailing_slash = this.extract_trailing_slash(parameters);
      result = "" + (this.get_prefix()) + (this.visit(route, parameters));
      url = Utils.clean_path("" + result);
      if (trailing_slash === true) {
        url = url.replace(/(.*?)[\/]?$/, "$1/");
      }
      if ((url_params = this.serialize(parameters)).length) {
        url += "?" + url_params;
      }
      url += anchor;
      return url;
    },
    visit: function(route, parameters, optional) {
      var left, left_part, right, right_part, type, value;

      if (optional == null) {
        optional = false;
      }
      type = route[0], left = route[1], right = route[2];
      switch (type) {
        case NodeTypes.GROUP:
          return this.visit(left, parameters, true);
        case NodeTypes.STAR:
          return this.visit_globbing(left, parameters, true);
        case NodeTypes.LITERAL:
        case NodeTypes.SLASH:
        case NodeTypes.DOT:
          return left;
        case NodeTypes.CAT:
          left_part = this.visit(left, parameters, optional);
          right_part = this.visit(right, parameters, optional);
          if (optional && !(left_part && right_part)) {
            return "";
          }
          return "" + left_part + right_part;
        case NodeTypes.SYMBOL:
          value = parameters[left];
          if (value != null) {
            delete parameters[left];
            return this.path_identifier(value);
          }
          if (optional) {
            return "";
          } else {
            throw new ParameterMissing("Route parameter missing: " + left);
          }
          break;
        default:
          throw new Error("Unknown Rails node type");
      }
    },
    build_path_spec: function(route, wildcard) {
      var left, right, type;

      if (wildcard == null) {
        wildcard = false;
      }
      type = route[0], left = route[1], right = route[2];
      switch (type) {
        case NodeTypes.GROUP:
          return "(" + (this.build_path_spec(left)) + ")";
        case NodeTypes.CAT:
          return "" + (this.build_path_spec(left)) + (this.build_path_spec(right));
        case NodeTypes.STAR:
          return this.build_path_spec(left, true);
        case NodeTypes.SYMBOL:
          if (wildcard === true) {
            return "" + (left[0] === '*' ? '' : '*') + left;
          } else {
            return ":" + left;
          }
          break;
        case NodeTypes.SLASH:
        case NodeTypes.DOT:
        case NodeTypes.LITERAL:
          return left;
        default:
          throw new Error("Unknown Rails node type");
      }
    },
    visit_globbing: function(route, parameters, optional) {
      var left, right, type, value;

      type = route[0], left = route[1], right = route[2];
      if (left.replace(/^\*/i, "") !== left) {
        route[1] = left = left.replace(/^\*/i, "");
      }
      value = parameters[left];
      if (value == null) {
        return this.visit(route, parameters, optional);
      }
      parameters[left] = (function() {
        switch (this.get_object_type(value)) {
          case "array":
            return value.join("/");
          default:
            return value;
        }
      }).call(this);
      return this.visit(route, parameters, optional);
    },
    get_prefix: function() {
      var prefix;

      prefix = defaults.prefix;
      if (prefix !== "") {
        prefix = (prefix.match("/$") ? prefix : "" + prefix + "/");
      }
      return prefix;
    },
    route: function(required_parts, optional_parts, route_spec) {
      var path_fn;

      path_fn = function() {
        return Utils.build_path(required_parts, optional_parts, route_spec, arguments);
      };
      path_fn.required_params = required_parts;
      path_fn.toString = function() {
        return Utils.build_path_spec(route_spec);
      };
      return path_fn;
    },
    _classToTypeCache: null,
    _classToType: function() {
      var name, _i, _len, _ref;

      if (this._classToTypeCache != null) {
        return this._classToTypeCache;
      }
      this._classToTypeCache = {};
      _ref = "Boolean Number String Function Array Date RegExp Object Error".split(" ");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        this._classToTypeCache["[object " + name + "]"] = name.toLowerCase();
      }
      return this._classToTypeCache;
    },
    get_object_type: function(obj) {
      if (root.jQuery && (root.jQuery.type != null)) {
        return root.jQuery.type(obj);
      }
      if (obj == null) {
        return "" + obj;
      }
      if (typeof obj === "object" || typeof obj === "function") {
        return this._classToType()[Object.prototype.toString.call(obj)] || "object";
      } else {
        return typeof obj;
      }
    }
  };

  createGlobalJsRoutesObject = function() {
    var namespace;

    namespace = function(mainRoot, namespaceString) {
      var current, parts;

      parts = (namespaceString ? namespaceString.split(".") : []);
      if (!parts.length) {
        return;
      }
      current = parts.shift();
      mainRoot[current] = mainRoot[current] || {};
      return namespace(mainRoot[current], parts.join("."));
    };
    namespace(root, "Routes");
    root.Routes = {
// accept_member_invitation => /:community_id/members/invitation/accept(.:format)
  // function(community_id, options)
  accept_member_invitation_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[6,"invitation",false],[2,[7,"/",false],[2,[6,"accept",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// cancel_member_registration => /:community_id/members/cancel(.:format)
  // function(community_id, options)
  cancel_member_registration_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[6,"cancel",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// communities => /
  // function(options)
  communities_path: Utils.route([], [], [7,"/",false], arguments),
// community => /:id(.:format)
  // function(id, options)
  community_path: Utils.route(["id"], ["format"], [2,[7,"/",false],[2,[3,"id",false],[1,[2,[8,".",false],[3,"format",false]],false]]], arguments),
// community_admin_community => /:community_id/admin/community(.:format)
  // function(community_id, options)
  community_admin_community_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"admin",false],[2,[7,"/",false],[2,[6,"community",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// community_admin_companies => /:community_id/admin/companies(.:format)
  // function(community_id, options)
  community_admin_companies_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"admin",false],[2,[7,"/",false],[2,[6,"companies",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// community_admin_company => /:community_id/admin/companies/:id(.:format)
  // function(community_id, id, options)
  community_admin_company_path: Utils.route(["community_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"admin",false],[2,[7,"/",false],[2,[6,"companies",false],[2,[7,"/",false],[2,[3,"id",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// community_admin_dashboard => /:community_id/admin/dashboard(.:format)
  // function(community_id, options)
  community_admin_dashboard_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"admin",false],[2,[7,"/",false],[2,[6,"dashboard",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// community_admin_event => /:community_id/admin/events/:id(.:format)
  // function(community_id, id, options)
  community_admin_event_path: Utils.route(["community_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"admin",false],[2,[7,"/",false],[2,[6,"events",false],[2,[7,"/",false],[2,[3,"id",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// community_admin_events => /:community_id/admin/events(.:format)
  // function(community_id, options)
  community_admin_events_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"admin",false],[2,[7,"/",false],[2,[6,"events",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// community_admin_member => /:community_id/admin/members/:id(.:format)
  // function(community_id, id, options)
  community_admin_member_path: Utils.route(["community_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"admin",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"id",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// community_admin_members => /:community_id/admin/members(.:format)
  // function(community_id, options)
  community_admin_members_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"admin",false],[2,[7,"/",false],[2,[6,"members",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// community_availability_calendar => /:community_id/availabilities/:year/:month/:day(.:format)
  // function(community_id, year, month, day, options)
  community_availability_calendar_path: Utils.route(["community_id","year","month","day"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"availabilities",false],[2,[7,"/",false],[2,[3,"year",false],[2,[7,"/",false],[2,[3,"month",false],[2,[7,"/",false],[2,[3,"day",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]], arguments),
// community_calendar => /:community_id/calendar(.:format)
  // function(community_id, options)
  community_calendar_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"calendar",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]], arguments),
// community_companies => /:community_id/companies(.:format)
  // function(community_id, options)
  community_companies_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"companies",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]], arguments),
// community_company => /:community_id/companies/:id(.:format)
  // function(community_id, id, options)
  community_company_path: Utils.route(["community_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"companies",false],[2,[7,"/",false],[2,[3,"id",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// community_company_member => /:community_id/companies/:company_id/members/:id(.:format)
  // function(community_id, company_id, id, options)
  community_company_member_path: Utils.route(["community_id","company_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"companies",false],[2,[7,"/",false],[2,[3,"company_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"id",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]], arguments),
// community_company_members => /:community_id/companies/:company_id/members(.:format)
  // function(community_id, company_id, options)
  community_company_members_path: Utils.route(["community_id","company_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"companies",false],[2,[7,"/",false],[2,[3,"company_id",false],[2,[7,"/",false],[2,[6,"members",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// community_discussion => /:community_id/discussions/:id(.:format)
  // function(community_id, id, options)
  community_discussion_path: Utils.route(["community_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"discussions",false],[2,[7,"/",false],[2,[3,"id",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// community_discussion_comment => /:community_id/discussions/:discussion_id/comments/:id(.:format)
  // function(community_id, discussion_id, id, options)
  community_discussion_comment_path: Utils.route(["community_id","discussion_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"discussions",false],[2,[7,"/",false],[2,[3,"discussion_id",false],[2,[7,"/",false],[2,[6,"comments",false],[2,[7,"/",false],[2,[3,"id",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]], arguments),
// community_discussion_comments => /:community_id/discussions/:discussion_id/comments(.:format)
  // function(community_id, discussion_id, options)
  community_discussion_comments_path: Utils.route(["community_id","discussion_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"discussions",false],[2,[7,"/",false],[2,[3,"discussion_id",false],[2,[7,"/",false],[2,[6,"comments",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// community_discussion_tag => /:community_id/discussions/tagged/:tag_id(.:format)
  // function(community_id, tag_id, options)
  community_discussion_tag_path: Utils.route(["community_id","tag_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"discussions",false],[2,[7,"/",false],[2,[6,"tagged",false],[2,[7,"/",false],[2,[3,"tag_id",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// community_discussions => /:community_id/discussions(.:format)
  // function(community_id, options)
  community_discussions_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"discussions",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]], arguments),
// community_event => /:community_id/events/:id(.:format)
  // function(community_id, id, options)
  community_event_path: Utils.route(["community_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"events",false],[2,[7,"/",false],[2,[3,"id",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// community_member => /:community_id/members/:id(.:format)
  // function(community_id, id, options)
  community_member_path: Utils.route(["community_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"id",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// community_member_activities => /:community_id/members/:member_id/activities(.:format)
  // function(community_id, member_id, options)
  community_member_activities_path: Utils.route(["community_id","member_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"member_id",false],[2,[7,"/",false],[2,[6,"activities",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// community_member_availabilities => /:community_id/members/:member_id/availabilities(.:format)
  // function(community_id, member_id, options)
  community_member_availabilities_path: Utils.route(["community_id","member_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"member_id",false],[2,[7,"/",false],[2,[6,"availabilities",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// community_member_availability => /:community_id/members/:member_id/availabilities/:id(.:format)
  // function(community_id, member_id, id, options)
  community_member_availability_path: Utils.route(["community_id","member_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"member_id",false],[2,[7,"/",false],[2,[6,"availabilities",false],[2,[7,"/",false],[2,[3,"id",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]], arguments),
// community_member_availability_slots => /:community_id/members/:member_id/availabilities/:year/:month/:day(.:format)
  // function(community_id, member_id, year, month, day, options)
  community_member_availability_slots_path: Utils.route(["community_id","member_id","year","month","day"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"member_id",false],[2,[7,"/",false],[2,[6,"availabilities",false],[2,[7,"/",false],[2,[3,"year",false],[2,[7,"/",false],[2,[3,"month",false],[2,[7,"/",false],[2,[3,"day",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]]]]]], arguments),
// community_member_calendar => /:community_id/members/:member_id/calendar(.:format)
  // function(community_id, member_id, options)
  community_member_calendar_path: Utils.route(["community_id","member_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"member_id",false],[2,[7,"/",false],[2,[6,"calendar",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// community_member_discussions => /:community_id/members/:member_id/discussions(.:format)
  // function(community_id, member_id, options)
  community_member_discussions_path: Utils.route(["community_id","member_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"member_id",false],[2,[7,"/",false],[2,[6,"discussions",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// community_member_message => /:community_id/members/:member_id/messages/:id(.:format)
  // function(community_id, member_id, id, options)
  community_member_message_path: Utils.route(["community_id","member_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"member_id",false],[2,[7,"/",false],[2,[6,"messages",false],[2,[7,"/",false],[2,[3,"id",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]], arguments),
// community_member_messages => /:community_id/members/:member_id/messages(.:format)
  // function(community_id, member_id, options)
  community_member_messages_path: Utils.route(["community_id","member_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"member_id",false],[2,[7,"/",false],[2,[6,"messages",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// community_members => /:community_id/members(.:format)
  // function(community_id, options)
  community_members_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]], arguments),
// community_messages => /:community_id/messages(.:format)
  // function(community_id, options)
  community_messages_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"messages",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]], arguments),
// destroy_member_session => /:community_id/members/sign_out(.:format)
  // function(community_id, options)
  destroy_member_session_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[6,"sign_out",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// edit_community => /:id/edit(.:format)
  // function(id, options)
  edit_community_path: Utils.route(["id"], ["format"], [2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"edit",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]], arguments),
// edit_community_admin_community => /:community_id/admin/community/edit(.:format)
  // function(community_id, options)
  edit_community_admin_community_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"admin",false],[2,[7,"/",false],[2,[6,"community",false],[2,[7,"/",false],[2,[6,"edit",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// edit_community_admin_company => /:community_id/admin/companies/:id/edit(.:format)
  // function(community_id, id, options)
  edit_community_admin_company_path: Utils.route(["community_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"admin",false],[2,[7,"/",false],[2,[6,"companies",false],[2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"edit",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]], arguments),
// edit_community_admin_event => /:community_id/admin/events/:id/edit(.:format)
  // function(community_id, id, options)
  edit_community_admin_event_path: Utils.route(["community_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"admin",false],[2,[7,"/",false],[2,[6,"events",false],[2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"edit",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]], arguments),
// edit_community_admin_member => /:community_id/admin/members/:id/edit(.:format)
  // function(community_id, id, options)
  edit_community_admin_member_path: Utils.route(["community_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"admin",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"edit",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]], arguments),
// edit_community_company => /:community_id/companies/:id/edit(.:format)
  // function(community_id, id, options)
  edit_community_company_path: Utils.route(["community_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"companies",false],[2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"edit",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// edit_community_company_member => /:community_id/companies/:company_id/members/:id/edit(.:format)
  // function(community_id, company_id, id, options)
  edit_community_company_member_path: Utils.route(["community_id","company_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"companies",false],[2,[7,"/",false],[2,[3,"company_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"edit",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]]]], arguments),
// edit_community_member_availability => /:community_id/members/:member_id/availabilities/:id/edit(.:format)
  // function(community_id, member_id, id, options)
  edit_community_member_availability_path: Utils.route(["community_id","member_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"member_id",false],[2,[7,"/",false],[2,[6,"availabilities",false],[2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"edit",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]]]], arguments),
// edit_community_member_availability_slots => /:community_id/members/:member_id/availabilities/:availability_id/slots/:hour/:minute/edit(.:format)
  // function(community_id, member_id, availability_id, hour, minute, options)
  edit_community_member_availability_slots_path: Utils.route(["community_id","member_id","availability_id","hour","minute"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"member_id",false],[2,[7,"/",false],[2,[6,"availabilities",false],[2,[7,"/",false],[2,[3,"availability_id",false],[2,[7,"/",false],[2,[6,"slots",false],[2,[7,"/",false],[2,[3,"hour",false],[2,[7,"/",false],[2,[3,"minute",false],[2,[7,"/",false],[2,[6,"edit",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]]]]]]]]]], arguments),
// edit_community_member_message => /:community_id/members/:member_id/messages/:id/edit(.:format)
  // function(community_id, member_id, id, options)
  edit_community_member_message_path: Utils.route(["community_id","member_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"member_id",false],[2,[7,"/",false],[2,[6,"messages",false],[2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"edit",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]]]], arguments),
// edit_member_password => /:community_id/members/password/edit(.:format)
  // function(community_id, options)
  edit_member_password_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[6,"password",false],[2,[7,"/",false],[2,[6,"edit",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// edit_member_registration => /:community_id/members/edit(.:format)
  // function(community_id, options)
  edit_member_registration_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[6,"edit",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// follow_community_discussion => /:community_id/discussions/:id/follow(.:format)
  // function(community_id, id, options)
  follow_community_discussion_path: Utils.route(["community_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"discussions",false],[2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"follow",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// follow_community_member => /:community_id/members/:id/follow(.:format)
  // function(community_id, id, options)
  follow_community_member_path: Utils.route(["community_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"follow",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// member_confirmation => /:community_id/members/confirmation(.:format)
  // function(community_id, options)
  member_confirmation_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[6,"confirmation",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// member_invitation => /:community_id/members/invitation(.:format)
  // function(community_id, options)
  member_invitation_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[6,"invitation",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// member_password => /:community_id/members/password(.:format)
  // function(community_id, options)
  member_password_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[6,"password",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// member_registration => /:community_id/members(.:format)
  // function(community_id, options)
  member_registration_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]], arguments),
// member_session => /:community_id/members/sign_in(.:format)
  // function(community_id, options)
  member_session_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[6,"sign_in",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// new_community => /new(.:format)
  // function(options)
  new_community_path: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"new",false],[1,[2,[8,".",false],[3,"format",false]],false]]], arguments),
// new_community_admin_company => /:community_id/admin/companies/new(.:format)
  // function(community_id, options)
  new_community_admin_company_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"admin",false],[2,[7,"/",false],[2,[6,"companies",false],[2,[7,"/",false],[2,[6,"new",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// new_community_admin_event => /:community_id/admin/events/new(.:format)
  // function(community_id, options)
  new_community_admin_event_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"admin",false],[2,[7,"/",false],[2,[6,"events",false],[2,[7,"/",false],[2,[6,"new",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// new_community_admin_member => /:community_id/admin/members/new(.:format)
  // function(community_id, options)
  new_community_admin_member_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"admin",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[6,"new",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// new_community_company_member => /:community_id/companies/:company_id/members/new(.:format)
  // function(community_id, company_id, options)
  new_community_company_member_path: Utils.route(["community_id","company_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"companies",false],[2,[7,"/",false],[2,[3,"company_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[6,"new",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]], arguments),
// new_community_discussion => /:community_id/discussions/new(.:format)
  // function(community_id, options)
  new_community_discussion_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"discussions",false],[2,[7,"/",false],[2,[6,"new",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// new_community_member_availability => /:community_id/members/:member_id/availabilities/new(.:format)
  // function(community_id, member_id, options)
  new_community_member_availability_path: Utils.route(["community_id","member_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"member_id",false],[2,[7,"/",false],[2,[6,"availabilities",false],[2,[7,"/",false],[2,[6,"new",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]], arguments),
// new_community_member_availability_slots => /:community_id/members/:member_id/availabilities/:availability_id/slots/:hour/:minute/new(.:format)
  // function(community_id, member_id, availability_id, hour, minute, options)
  new_community_member_availability_slots_path: Utils.route(["community_id","member_id","availability_id","hour","minute"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"member_id",false],[2,[7,"/",false],[2,[6,"availabilities",false],[2,[7,"/",false],[2,[3,"availability_id",false],[2,[7,"/",false],[2,[6,"slots",false],[2,[7,"/",false],[2,[3,"hour",false],[2,[7,"/",false],[2,[3,"minute",false],[2,[7,"/",false],[2,[6,"new",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]]]]]]]]]], arguments),
// new_community_member_message => /:community_id/members/:member_id/messages/new(.:format)
  // function(community_id, member_id, options)
  new_community_member_message_path: Utils.route(["community_id","member_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"member_id",false],[2,[7,"/",false],[2,[6,"messages",false],[2,[7,"/",false],[2,[6,"new",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]], arguments),
// new_member_confirmation => /:community_id/members/confirmation/new(.:format)
  // function(community_id, options)
  new_member_confirmation_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[6,"confirmation",false],[2,[7,"/",false],[2,[6,"new",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// new_member_invitation => /:community_id/members/invitation/new(.:format)
  // function(community_id, options)
  new_member_invitation_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[6,"invitation",false],[2,[7,"/",false],[2,[6,"new",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// new_member_password => /:community_id/members/password/new(.:format)
  // function(community_id, options)
  new_member_password_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[6,"password",false],[2,[7,"/",false],[2,[6,"new",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// new_member_registration => /:community_id/members/sign_up(.:format)
  // function(community_id, options)
  new_member_registration_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[6,"sign_up",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// new_member_session => /:community_id/members/sign_in(.:format)
  // function(community_id, options)
  new_member_session_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[6,"sign_in",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// rails_info => /rails/info(.:format)
  // function(options)
  rails_info_path: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"rails",false],[2,[7,"/",false],[2,[6,"info",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]], arguments),
// rails_info_properties => /rails/info/properties(.:format)
  // function(options)
  rails_info_properties_path: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"rails",false],[2,[7,"/",false],[2,[6,"info",false],[2,[7,"/",false],[2,[6,"properties",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// rails_info_routes => /rails/info/routes(.:format)
  // function(options)
  rails_info_routes_path: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"rails",false],[2,[7,"/",false],[2,[6,"info",false],[2,[7,"/",false],[2,[6,"routes",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// rails_mailers => /rails/mailers(.:format)
  // function(options)
  rails_mailers_path: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"rails",false],[2,[7,"/",false],[2,[6,"mailers",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]], arguments),
// release_community_member_availability_slots => /:community_id/members/:member_id/availabilities/:availability_id/slots/:hour/:minute/release(.:format)
  // function(community_id, member_id, availability_id, hour, minute, options)
  release_community_member_availability_slots_path: Utils.route(["community_id","member_id","availability_id","hour","minute"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"member_id",false],[2,[7,"/",false],[2,[6,"availabilities",false],[2,[7,"/",false],[2,[3,"availability_id",false],[2,[7,"/",false],[2,[6,"slots",false],[2,[7,"/",false],[2,[3,"hour",false],[2,[7,"/",false],[2,[3,"minute",false],[2,[7,"/",false],[2,[6,"release",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]]]]]]]]]], arguments),
// remove_member_invitation => /:community_id/members/invitation/remove(.:format)
  // function(community_id, options)
  remove_member_invitation_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[6,"invitation",false],[2,[7,"/",false],[2,[6,"remove",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// resend_invitation_community_admin_member => /:community_id/admin/members/:id/resend_invitation(.:format)
  // function(community_id, id, options)
  resend_invitation_community_admin_member_path: Utils.route(["community_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"admin",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"resend_invitation",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]], arguments),
// reserve_community_member_availability_slots => /:community_id/members/:member_id/availabilities/:availability_id/slots/:hour/:minute/reserve(.:format)
  // function(community_id, member_id, availability_id, hour, minute, options)
  reserve_community_member_availability_slots_path: Utils.route(["community_id","member_id","availability_id","hour","minute"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"member_id",false],[2,[7,"/",false],[2,[6,"availabilities",false],[2,[7,"/",false],[2,[3,"availability_id",false],[2,[7,"/",false],[2,[6,"slots",false],[2,[7,"/",false],[2,[3,"hour",false],[2,[7,"/",false],[2,[3,"minute",false],[2,[7,"/",false],[2,[6,"reserve",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]]]]]]]]]]]], arguments),
// root => /
  // function(options)
  root_path: Utils.route([], [], [7,"/",false], arguments),
// rsvp_community_event => /:community_id/events/:id/rsvp(.:format)
  // function(community_id, id, options)
  rsvp_community_event_path: Utils.route(["community_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"events",false],[2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"rsvp",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// s3_callback => /s3_callback/:model(.:format)
  // function(model, options)
  s3_callback_path: Utils.route(["model"], ["format"], [2,[7,"/",false],[2,[6,"s3_callback",false],[2,[7,"/",false],[2,[3,"model",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]], arguments),
// search_community_messages => /:community_id/messages/search(.:format)
  // function(community_id, options)
  search_community_messages_path: Utils.route(["community_id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"messages",false],[2,[7,"/",false],[2,[6,"search",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]], arguments),
// unfollow_community_discussion => /:community_id/discussions/:id/unfollow(.:format)
  // function(community_id, id, options)
  unfollow_community_discussion_path: Utils.route(["community_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"discussions",false],[2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"unfollow",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments),
// unfollow_community_member => /:community_id/members/:id/unfollow(.:format)
  // function(community_id, id, options)
  unfollow_community_member_path: Utils.route(["community_id","id"], ["format"], [2,[7,"/",false],[2,[3,"community_id",false],[2,[7,"/",false],[2,[6,"members",false],[2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"unfollow",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]]], arguments)}
;
    root.Routes.options = defaults;
    return root.Routes;
  };

  if (typeof define === "function" && define.amd) {
    define([], function() {
      return createGlobalJsRoutesObject();
    });
  } else {
    createGlobalJsRoutesObject();
  }

}).call(this);
