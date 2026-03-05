.class Landroidx/savedstate/SavedStateRegistry$1;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Landroidx/lifecycle/e;


# virtual methods
.method public g(Landroidx/lifecycle/g;Landroidx/lifecycle/d$b;)V
    .locals 1

    sget-object p1, Landroidx/lifecycle/d$b;->ON_START:Landroidx/lifecycle/d$b;

    const/4 v0, 0x0

    if-eq p2, p1, :cond_1

    sget-object p1, Landroidx/lifecycle/d$b;->ON_STOP:Landroidx/lifecycle/d$b;

    if-eq p2, p1, :cond_0

    return-void

    :cond_0
    throw v0

    :cond_1
    throw v0
.end method
