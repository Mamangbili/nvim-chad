local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s("enum", {
		i(1, "Name"),
		t(" :: enum {"),
		t({ "", "\t" }),
		i(0),
		t({ "", "}" }),
	}),

	s("union", {
		i(1, "Name"),
		t(" :: union {"),
		t({ "", "\t" }),
		i(0),
		t({ "", "}" }),
	}),

	s("swi", {
		t("switch "),
		i(1, "value"),
		t(" {"),
		t({ "", "case " }),
		i(2, "condition"),
		t(":"),
		t({ "", "\t" }),
		i(0),
		t({ "", "}" }),
	}),

	s("swit", {
		t("switch "),
		i(1, "v"),
		t(" in "),
		i(2, "value"),
		t(" {"),
		t({ "", "case " }),
		i(3, "Type"),
		t(":"),
		t({ "", "\t" }),
		i(0),
		t({ "", "}" }),
	}),

	s("enumarr", {
		i(1, "name"),
		t(" := ["),
		i(2, "index"),
		t("]"),
		i(3, "type"),
		t({ "{", "\t" }),
		i(0),
		t({ "", "}" }),
	}),
}
