.class public Lf0/a;
.super Ljava/lang/Object;
.source "SourceFile"


# direct methods
.method public static a(Lc0/c;)Landroidx/lifecycle/d;
    .locals 0

    invoke-interface {p0}, Lc0/c;->a()Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lio/flutter/embedding/engine/plugins/lifecycle/HiddenLifecycleReference;

    invoke-virtual {p0}, Lio/flutter/embedding/engine/plugins/lifecycle/HiddenLifecycleReference;->getLifecycle()Landroidx/lifecycle/d;

    move-result-object p0

    return-object p0
.end method
