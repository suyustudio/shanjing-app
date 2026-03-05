.class public final Landroidx/core/view/b0;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Landroidx/core/view/b0$d;,
        Landroidx/core/view/b0$c;,
        Landroidx/core/view/b0$b;,
        Landroidx/core/view/b0$a;,
        Landroidx/core/view/b0$e;
    }
.end annotation


# instance fields
.field private final a:Landroidx/core/view/b0$e;


# direct methods
.method public constructor <init>(Landroid/view/Window;Landroid/view/View;)V
    .locals 2

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1e

    if-lt v0, v1, :cond_0

    new-instance p2, Landroidx/core/view/b0$d;

    invoke-direct {p2, p1, p0}, Landroidx/core/view/b0$d;-><init>(Landroid/view/Window;Landroidx/core/view/b0;)V

    iput-object p2, p0, Landroidx/core/view/b0;->a:Landroidx/core/view/b0$e;

    goto :goto_1

    :cond_0
    const/16 v1, 0x1a

    if-lt v0, v1, :cond_1

    new-instance v0, Landroidx/core/view/b0$c;

    invoke-direct {v0, p1, p2}, Landroidx/core/view/b0$c;-><init>(Landroid/view/Window;Landroid/view/View;)V

    :goto_0
    iput-object v0, p0, Landroidx/core/view/b0;->a:Landroidx/core/view/b0$e;

    goto :goto_1

    :cond_1
    const/16 v1, 0x17

    if-lt v0, v1, :cond_2

    new-instance v0, Landroidx/core/view/b0$b;

    invoke-direct {v0, p1, p2}, Landroidx/core/view/b0$b;-><init>(Landroid/view/Window;Landroid/view/View;)V

    goto :goto_0

    :cond_2
    new-instance v0, Landroidx/core/view/b0$a;

    invoke-direct {v0, p1, p2}, Landroidx/core/view/b0$a;-><init>(Landroid/view/Window;Landroid/view/View;)V

    goto :goto_0

    :goto_1
    return-void
.end method


# virtual methods
.method public a(Z)V
    .locals 1

    iget-object v0, p0, Landroidx/core/view/b0;->a:Landroidx/core/view/b0$e;

    invoke-virtual {v0, p1}, Landroidx/core/view/b0$e;->a(Z)V

    return-void
.end method

.method public b(Z)V
    .locals 1

    iget-object v0, p0, Landroidx/core/view/b0;->a:Landroidx/core/view/b0$e;

    invoke-virtual {v0, p1}, Landroidx/core/view/b0$e;->b(Z)V

    return-void
.end method
