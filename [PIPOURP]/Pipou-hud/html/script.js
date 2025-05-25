window.addEventListener("message", function (event) {
    const data = event.data;

    if (data.action === "updateHud") {
        document.getElementById('fill-health').style.width = `${data.health}%`;
        document.getElementById('fill-hunger').style.width = `${data.hunger}%`;
        document.getElementById('fill-thirst').style.width = `${data.thirst}%`;

        const voiceFill = document.getElementById('fill-voice');
        if (voiceFill) {
            const widths = [30, 60, 100]; // whisper, normal, shout
            voiceFill.style.width = `${widths[data.voiceMode] || 60}%`;
        }
    }

    if (data.action === "setTalking") {
        const icon = document.getElementById("mic-icon");
        const voiceFill = document.getElementById("fill-voice");

        if (icon) {
            if (data.talking) {
                icon.classList.add("talking");
            } else {
                icon.classList.remove("talking");
            }
        }

        if (voiceFill) {
            if (data.talking) {
                voiceFill.classList.add("talking");
            } else {
                voiceFill.classList.remove("talking");
            }
        }
    }

    if (data.action === "setVoiceMode") {
        const voiceFill = document.getElementById('fill-voice');
        if (voiceFill) {
            const widths = [30, 60, 100]; // whisper, normal, shout
            voiceFill.style.width = `${widths[data.mode] || 60}%`;
        }
    }

    if (data.action === "radioTalking") {
        const icon = document.getElementById("mic-icon");
        if (icon) {
            if (data.active) {
                icon.classList.add("radio");
            } else {
                icon.classList.remove("radio");
            }
        }
    }
});
