using System;
using Velopack;
using Velopack.Locators;

namespace AMWin_RichPresence {
    internal static class Program {
        internal const string ForkAppId = "PIXELHIZE.AMWin-RP";
        internal const string ForkRepositoryUrl = "https://github.com/PIXELHIZE/AMWin-RP";

        internal static bool UsesForkUpdates =>
            string.Equals(VelopackLocator.Current.AppId, ForkAppId, StringComparison.OrdinalIgnoreCase);

        internal static bool RestartedForUpdate { get; private set; }

        [STAThread]
        public static void Main() {
            // Let Velopack handle installer callbacks before WPF or Discord starts.
            // The app applies staged updates only when the startup update setting is enabled.
            VelopackApp.Build()
                .SetAutoApplyOnStartup(false)
                .OnRestarted(_ => RestartedForUpdate = true)
                .Run();

            var app = new App();
            app.InitializeComponent();
            app.Run();
        }
    }
}
