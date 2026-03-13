// web-content-fetcher 技能
// 这是对 OpenClaw 内置 web_fetch 工具的包装，提供你喜欢的技能名称

module.exports = {
  name: "web-content-fetcher",
  tools: {
    // 这个技能会使用 OpenClaw 内置的 web_fetch 工具
    // web_fetch 工具已经内置并默认启用，可以直接使用
    // 使用方式: await web_fetch({ url: "...", extractMode: "markdown", maxChars: 50000 })
  },
};

console.log("✅ web-content-fetcher 技能已加载！使用 OpenClaw 内置的 web_fetch 工具提供功能。");
