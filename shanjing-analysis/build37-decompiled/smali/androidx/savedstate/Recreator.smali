.class final Landroidx/savedstate/Recreator;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Landroidx/lifecycle/e;


# annotations
.annotation build Landroid/annotation/SuppressLint;
    value = {
        "RestrictedApi"
    }
.end annotation


# instance fields
.field private final a:Landroidx/savedstate/b;


# virtual methods
.method public g(Landroidx/lifecycle/g;Landroidx/lifecycle/d$b;)V
    .locals 1

    sget-object v0, Landroidx/lifecycle/d$b;->ON_CREATE:Landroidx/lifecycle/d$b;

    if-eq p2, v0, :cond_0

    new-instance p1, Ljava/lang/AssertionError;

    const-string p2, "Next event must be ON_CREATE"

    invoke-direct {p1, p2}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V

    throw p1

    :cond_0
    invoke-interface {p1}, Landroidx/lifecycle/g;->a()Landroidx/lifecycle/d;

    move-result-object p1

    invoke-virtual {p1, p0}, Landroidx/lifecycle/d;->c(Landroidx/lifecycle/f;)V

    iget-object p1, p0, Landroidx/savedstate/Recreator;->a:Landroidx/savedstate/b;

    invoke-interface {p1}, Landroidx/savedstate/b;->k()Landroidx/savedstate/a;

    const/4 p1, 0x0

    throw p1
.end method
