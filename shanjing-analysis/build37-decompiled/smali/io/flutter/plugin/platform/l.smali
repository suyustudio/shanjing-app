.class public abstract Lio/flutter/plugin/platform/l;
.super Ljava/lang/Object;
.source "SourceFile"


# instance fields
.field private final a:Lj0/i;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lj0/i<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method public constructor <init>(Lj0/i;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lj0/i<",
            "Ljava/lang/Object;",
            ">;)V"
        }
    .end annotation

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lio/flutter/plugin/platform/l;->a:Lj0/i;

    return-void
.end method


# virtual methods
.method public abstract a(Landroid/content/Context;ILjava/lang/Object;)Lio/flutter/plugin/platform/k;
.end method

.method public final b()Lj0/i;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Lj0/i<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation

    iget-object v0, p0, Lio/flutter/plugin/platform/l;->a:Lj0/i;

    return-object v0
.end method
